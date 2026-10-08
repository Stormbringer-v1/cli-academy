#!/usr/bin/env bash
# tests/lint-levels.sh - static lint for CLI Academy games and levels.
#
# Enforces the structural rules of docs/engine-contract.md (section 1 layout and
# naming, section 2 sandbox rules, section 8 validation config, section 9 shebangs
# and exec bits) for every game under games/, or for the games named on the
# command line.
#
# The lint NEVER executes level code. The only thing it lets bash evaluate is
# plain variable assignments in level.conf (see LINT_INNER below); every other
# command in a level file is intercepted before it runs.
#
# Usage: tests/lint-levels.sh [--games-dir <dir>] [--list-rules] [-h|--help] [<game> ...]
# Exit:  0 = no findings, 1 = at least one finding, 2 = usage error.

set -uo pipefail
export LC_ALL=C
shopt -s nullglob

# needs associative arrays, mapfile and empty-array expansion under set -u
if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4))); then
  printf 'lint-levels.sh: bash >= 4.4 is required (this is %s)\n' "$BASH_VERSION" >&2
  exit 2
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P) || exit 2
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd -P) || exit 2

# ---------------------------------------------------------------------------
# Rule table (ID and one-line description)
# ---------------------------------------------------------------------------
RULES=(
  "G-PLAY-EXEC|play.sh has the exec bit (contract section 9)"
  "G-SHEBANG|every *.sh in a game dir and in its level dirs has a bash shebang on line 1 (section 9)"
  "G-SYNTAX|every such *.sh passes bash -n"
  "G-ORDER-PARSE|play.sh defines LEVEL_ORDER=( ... ) and every token matches ^[a-zA-Z0-9_]+\$ (section 1)"
  "G-ORDER-DUP|no LEVEL_ORDER token is listed twice"
  "G-ORDER-MISSING|every LEVEL_ORDER token has a levels/level<ID>/ directory (section 1)"
  "G-DIR-NAME|every entry of levels/ is a directory named level<ID> (section 1)"
  "G-DIR-ORPHAN|every levels/level<ID>/ directory is listed in LEVEL_ORDER (section 1)"
  "G-COMMON-TOPLEVEL|*_common.sh has only source, assignments and function definitions at top level (section 2)"
  "G-COMMON-FORBIDDEN|*_common.sh has no cd, pushd, popd, trap, exit, rm -r, mktemp or SANDBOX_DIR= (section 2)"
  "L-FILES|a level has level.conf, template.txt and hint.txt (section 1)"
  "L-CONF-STMT|level.conf contains only variable assignments"
  "L-CONF-KEYS|NAME, TIER, TOOL_CMD and VALIDATION_TYPE are set; VALIDATION_TYPE is a known type (section 8)"
  "L-CONF-RULES|the validation type has the variable it needs: MUST_*, EXPECTED_FILE or VALIDATION_COMMAND (section 8)"
  "L-VALIDATE-MISSING|VALIDATION_TYPE=script and the validator file exists (section 8)"
  "L-VALIDATE-EXEC|the validator script is executable (section 9)"
  "L-VALIDATE-FAILPATH|the validator script has a failure path (exit/return N>0, or a trailing validate_* helper)"
  "L-SBX-TOPLEVEL|sandbox.sh has only source, assignments and function definitions at top level (section 2)"
  "L-SBX-FORBIDDEN|sandbox.sh has no cd, pushd, popd, trap, exit, rm -r, mktemp or SANDBOX_DIR= (section 2)"
)

VALIDATION_TYPES="content_check file_exists diff_check command_check script"
TOKEN_RE='^[a-zA-Z0-9_]+$'

usage() {
  cat <<'EOF'
Usage: tests/lint-levels.sh [--games-dir <dir>] [--list-rules] [-h|--help] [<game> ...]

Static lint for CLI Academy games (docs/engine-contract.md sections 1, 2, 8, 9).
Level code is never executed.

  <game> ...        lint only these games (names of directories under the games dir);
                    without arguments every directory <games-dir>/*/ is linted.
                    Games are always processed in sorted order.
  --games-dir <dir> games directory (default: <repo>/games, resolved from this script)
  --list-rules      print "<RULE-ID>  <description>" for every rule and exit 0
  -h, --help        print this text and exit 0

Output: one line per finding, "<path>:<line>: <RULE-ID>: <message>" (path relative to
the repo root), a "== <game>: <n> levels, <k> findings" line per game and a final
"TOTAL:" line.  Exit status: 0 no findings, 1 findings, 2 usage error.
EOF
}

die_usage() {
  printf 'lint-levels.sh: %s\n' "$1" >&2
  printf 'Try tests/lint-levels.sh --help\n' >&2
  exit 2
}

# ---------------------------------------------------------------------------
# Static evaluation of level files WITHOUT running them
#
# The file is sourced in a clean bash with a DEBUG trap under extdebug. When the
# trap handler returns non-zero, bash SKIPS the command, so nothing from the file
# runs. In "conf" mode plain assignments are allowed to run so their values can
# be read; commands inside $(...) in an assignment are still reported and
# skipped, because extdebug makes command substitutions inherit the trap.
#
# Hardening over the bare technique (found by probing it):
#  - "FOO=1 touch x", "A=1 >file" and "D=1 source other" begin with an assignment
#    but run a command or create a file. __plain is a quote-aware scanner that
#    only accepts a statement made of NAME=value words, so these are reported
#    and skipped instead of being waved through as assignments.
#  - the handler state is readonly, so a level file cannot switch the guard off.
# ---------------------------------------------------------------------------
LINT_INNER=$(cat <<'INNER'
__f=$1; __mode=$2; shift 2
readonly __f __mode
__is_assign() { [[ $1 =~ ^[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?\+?= ]]; }
# __plain <statement>: 0 = only NAME=value words, 1 = a command word or a
# redirection follows the assignments, 2 = could not tell (unbalanced quoting).
__plain() {
  local s=$1 n=${#1} i c nx top stack="" inword=0
  # fast path: one assignment of a bare word or of a simple double-quoted string
  [[ $s =~ ^[A-Za-z_][A-Za-z0-9_]*=(\"[^\"\$\`\\]*\"|[^[:space:]\"\'\$\`\\\;\&\|\<\>\(\)]*)$ ]] && return 0
  for ((i = 0; i < n; i++)); do
    c=${s:i:1}; nx=${s:i+1:1}; top=${stack: -1}
    if [[ -z $stack ]]; then
      if [[ $c == [[:space:]] ]]; then inword=0; continue; fi
      if ((inword == 0)); then
        [[ ${s:i} =~ ^[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?\+?= ]] || return 1
        inword=1
      fi
      case $c in ';' | '&' | '|' | '<' | '>') return 1 ;; esac
    fi
    case $top in
      "'") [[ $c == "'" ]] && stack=${stack%?} ;;
      A) if [[ $c == '\' ]]; then i=$((i + 1)); elif [[ $c == "'" ]]; then stack=${stack%?}; fi ;;
      '"')
        case $c in
          '\') i=$((i + 1)) ;;
          '"') stack=${stack%?} ;;
          '$') if [[ $nx == '(' ]]; then stack+=')'; i=$((i + 1)); elif [[ $nx == '{' ]]; then stack+='}'; i=$((i + 1)); fi ;;
          '`') stack+='`' ;;
        esac ;;
      *)
        case $c in
          '\') i=$((i + 1)) ;;
          "'") stack+="'" ;;
          '"') stack+='"' ;;
          '$')
            if [[ $nx == '(' ]]; then stack+=')'; i=$((i + 1))
            elif [[ $nx == '{' ]]; then stack+='}'; i=$((i + 1))
            elif [[ $nx == "'" ]]; then stack+='A'; i=$((i + 1)); fi ;;
          '`') if [[ $top == '`' ]]; then stack=${stack%?}; else stack+='`'; fi ;;
          '(') stack+=')' ;;
          ')') [[ $top == ')' ]] && stack=${stack%?} ;;
          '}') [[ $top == '}' ]] && stack=${stack%?} ;;
        esac ;;
    esac
  done
  [[ -z $stack ]] || return 2
  return 0
}
__other_allowed() {
  [[ $1 =~ ^(source|\.)[[:space:]] ]] ||
  [[ $1 =~ ^(export|readonly|declare)([[:space:]]+-[a-zA-Z]+)*[[:space:]]+[A-Za-z_][A-Za-z0-9_]*(=|$) ]]
}
__t() {
  [[ ${BASH_SOURCE[1]:-} == "$__f" ]] || return 0
  local __rc=1
  if __is_assign "$2"; then
    __plain "$2"; __rc=$?
    if ((__rc == 0)); then
      if [[ $__mode == conf ]]; then return 0; fi
      return 1
    fi
    # not provably an assignment: never run it; in skip mode stay quiet when unsure
    if ((__rc == 2)) && [[ $__mode == skip ]]; then return 1; fi
  elif __other_allowed "$2"; then
    return 1
  fi
  printf 'STMT\t%s\t%s\n' "$1" "${2//$'\n'/ }" >&3
  return 1
}
readonly -f __is_assign __plain __other_allowed __t
shopt -s extdebug
trap '__t "$LINENO" "$BASH_COMMAND"' DEBUG
source "$__f"
trap - DEBUG
if [[ $__mode == conf ]]; then
  for __v in "$@"; do
    if declare -p "$__v" >/dev/null 2>&1; then
      __val=$(declare -p "$__v" 2>/dev/null)
      if [[ $__val == "declare -a"* ]]; then
        eval "__n=\${#$__v[@]}"; printf 'VAR\t%s\t<array:%s>\n' "$__v" "$__n" >&3; continue
      fi
      printf 'VAR\t%s\t%s\n' "$__v" "${!__v//$'\n'/ }" >&3
    fi
  done
fi
INNER
)

# usage: lint_inner <ABSOLUTE file> skip         -> lines "STMT<TAB><line><TAB><command>"
#        lint_inner <ABSOLUTE file> conf VAR...  -> STMT lines plus "VAR<TAB><name><TAB><value>" per set VAR
lint_inner() { env -i PATH="$PATH" bash --norc --noprofile -c "$LINT_INNER" lint-inner "$@" 3>&1 >/dev/null 2>&1; }

# ---------------------------------------------------------------------------
# Forbidden-pattern heuristics for sandbox code (section 8.3)
# ---------------------------------------------------------------------------
CMDPOS='(^|;|&&|\|\||\{|\bthen\b|\bdo\b|\belse\b)[[:space:]]*'
RE_CMD="${CMDPOS}(cd|pushd|popd|trap|exit)([[:space:]]|;|\$)"
RE_RM="${CMDPOS}rm[[:space:]]+-[a-zA-Z]*[rR]"
RE_MKTEMP='\bmktemp\b'
RE_SBXDIR="${CMDPOS}(export[[:space:]]+)?SANDBOX_DIR="
RE_FAILPATH='\b(exit|return)[[:space:]]+[1-9]'

WHAT=''
# find_forbidden <prepared line>: sets WHAT to the first forbidden construct, '' if none
find_forbidden() {
  WHAT=''
  if [[ $1 =~ $RE_CMD ]]; then WHAT=${BASH_REMATCH[2]}
  elif [[ $1 =~ $RE_RM ]]; then WHAT='rm -r'
  elif [[ $1 =~ $RE_MKTEMP ]]; then WHAT='mktemp'
  elif [[ $1 =~ $RE_SBXDIR ]]; then WHAT='assignment to SANDBOX_DIR'
  fi
}

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
GAME_FINDINGS=0
REL=''

# rel <abs path>: sets REL to the path relative to the repo root (or the path itself)
rel() {
  if [[ $1 == "$REPO_ROOT"/* ]]; then REL=${1#"$REPO_ROOT"/}; else REL=$1; fi
}

# emit <abs path> <line|""> <RULE-ID> <message>
emit() {
  rel "$1"
  local loc=$REL
  [[ -n $2 ]] && loc+=":$2"
  printf '%s: %s: %s\n' "$loc" "$3" "$4"
  GAME_FINDINGS=$((GAME_FINDINGS + 1))
}

# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

# toplevel_findings <abs file> <RULE-ID>: top-level statements other than source/assignments
toplevel_findings() {
  local f=$1 rule=$2 out kind ln cmd
  out=$(lint_inner "$f" skip)
  while IFS=$'\t' read -r kind ln cmd; do
    [[ $kind == STMT ]] || continue
    ((${#cmd} > 80)) && cmd="${cmd:0:80}..."
    emit "$f" "$ln" "$rule" "top-level statement '$cmd' (only source, assignments and function definitions are allowed; contract §2)"
  done <<<"$out"
}

# forbidden_findings <abs file> <RULE-ID>: section 8.3 line heuristics
forbidden_findings() {
  local f=$1 rule=$2 i trimmed
  local -a raw=() prep=()
  mapfile -t raw <"$f"
  mapfile -t prep < <(sed -E \
    -e 's/^[[:space:]]*#.*$//' \
    -e 's/[[:space:]]#.*$//' \
    -e 's/\$\([[:space:]]*cd[[:space:]]/$( /g' "$f")
  for i in "${!prep[@]}"; do
    [[ -n ${prep[i]} ]] || continue
    find_forbidden "${prep[i]}"
    [[ -n $WHAT ]] || continue
    trimmed=${raw[i]-}
    [[ $trimmed =~ ^[[:space:]]*(.*[^[:space:]])[[:space:]]*$ ]] && trimmed=${BASH_REMATCH[1]}
    emit "$f" "$((i + 1))" "$rule" "'$WHAT' is not allowed in sandbox code (contract §2): $trimmed"
  done
}

# order_line <play.sh> <token> <occurrence>: line number of the n-th occurrence of a token
order_line() {
  awk -v t="$2" -v k="$3" '
    /^[[:space:]]*LEVEL_ORDER=\(/ { f = 1 }
    f {
      l = $0
      sub(/#.*$/, "", l); sub(/^[[:space:]]*LEVEL_ORDER=\(/, "", l); sub(/\).*$/, "", l)
      gsub(/["'"'"']/, "", l)
      n = split(l, a, /[ \t]+/)
      for (i = 1; i <= n; i++) if (a[i] == t && ++c == k) { print NR; exit }
    }
    f && /\)/ { exit }' "$1"
}

declare -A HELPERS=()
HELPERS_READY=0
# build_helpers <game dir>: validate_* functions defined in game-level scripts that have a failure path
build_helpers() {
  local gdir=$1 f content name
  HELPERS=()
  HELPERS_READY=1
  for f in "$gdir"/*.sh; do
    content=$(grep -v -E '^[[:space:]]*#' "$f")
    [[ $content =~ $RE_FAILPATH ]] || continue
    while IFS= read -r name; do
      [[ -n $name ]] && HELPERS[$name]=1
    done < <(grep -E -o '^[[:space:]]*(function[[:space:]]+)?validate_[A-Za-z0-9_]+[[:space:]]*\(\)' "$f" |
      sed -E -e 's/^[[:space:]]*(function[[:space:]]+)?//' -e 's/[[:space:]]*\(\)$//')
  done
}

# has_failpath <abs validator> <game dir>: section 8.4
has_failpath() {
  local f=$1 gdir=$2 content last name
  content=$(grep -v -E '^[[:space:]]*#' "$f")
  [[ $content =~ $RE_FAILPATH ]] && return 0
  last=$(printf '%s\n' "$content" | sed -e '/^[[:space:]]*$/d' | tail -n 1)
  if [[ $last =~ ^[[:space:]]*(validate_[A-Za-z0-9_]+)[[:space:]]*$ ]]; then
    name=${BASH_REMATCH[1]}
    ((HELPERS_READY)) || build_helpers "$gdir"
    [[ -n ${HELPERS[$name]+x} ]] && return 0
  fi
  return 1
}

declare -A CONF=()
# conf_nonempty <VAR>: set, and non-empty (an array counts when it has elements)
conf_nonempty() {
  local v
  [[ -n ${CONF[$1]+x} ]] || return 1
  v=${CONF[$1]}
  if [[ $v =~ ^\<array:([0-9]+)\>$ ]]; then
    ((BASH_REMATCH[1] > 0))
    return
  fi
  [[ -n $v ]]
}

CONF_VARS=(NAME TIER TOOL_CMD VALIDATION_TYPE VALIDATION_SCRIPT VALIDATION_COMMAND EXPECTED_FILE MUST_CONTAIN MUST_NOT_CONTAIN)

# check_conf <level dir>: L-CONF-STMT, L-CONF-KEYS, L-CONF-RULES (level.conf must exist)
check_conf() {
  local ldir=$1 conf=$1/level.conf out kind a b key vt ok
  CONF=()
  out=$(lint_inner "$conf" conf "${CONF_VARS[@]}")
  while IFS=$'\t' read -r kind a b; do
    case $kind in
      STMT) ((${#b} > 80)) && b="${b:0:80}..."
        emit "$conf" "$a" L-CONF-STMT "level.conf must only contain assignments; found '$b'" ;;
      VAR) CONF[$a]=$b ;;
    esac
  done <<<"$out"

  for key in NAME TIER TOOL_CMD VALIDATION_TYPE; do
    conf_nonempty "$key" || emit "$conf" "" L-CONF-KEYS "$key is not set"
  done
  vt=''
  if conf_nonempty VALIDATION_TYPE; then
    vt=${CONF[VALIDATION_TYPE]}
    ok=0
    for key in $VALIDATION_TYPES; do [[ $vt == "$key" ]] && ok=1; done
    if ((ok == 0)); then
      emit "$conf" "" L-CONF-KEYS "VALIDATION_TYPE '$vt' is not one of $VALIDATION_TYPES"
      vt=''
    fi
  fi
  CONF_TYPE=$vt

  case $vt in
    content_check)
      conf_nonempty MUST_CONTAIN || conf_nonempty MUST_NOT_CONTAIN ||
        emit "$conf" "" L-CONF-RULES "content_check without MUST_CONTAIN or MUST_NOT_CONTAIN would always pass or always fail" ;;
    file_exists | diff_check)
      conf_nonempty EXPECTED_FILE ||
        emit "$conf" "" L-CONF-RULES "$vt without EXPECTED_FILE would always pass or always fail" ;;
    command_check)
      conf_nonempty VALIDATION_COMMAND ||
        emit "$conf" "" L-CONF-RULES "command_check without VALIDATION_COMMAND would always pass or always fail" ;;
  esac
}

CONF_TYPE=''
# lint_level <game dir> <ID>
lint_level() {
  local gdir=$1 id=$2 ldir=$1/levels/level$2 file vfile vname
  for file in level.conf template.txt hint.txt; do
    [[ -f $ldir/$file ]] || emit "$ldir" "" L-FILES "missing $file (contract §1)"
  done

  CONF_TYPE=''
  [[ -f $ldir/level.conf ]] && check_conf "$ldir"

  if [[ $CONF_TYPE == script ]]; then
    vname=validate.sh
    conf_nonempty VALIDATION_SCRIPT && [[ ${CONF[VALIDATION_SCRIPT]} != '<array:'* ]] && vname=${CONF[VALIDATION_SCRIPT]}
    vfile=$ldir/$vname
    if [[ ! -f $vfile ]]; then
      emit "$ldir" "" L-VALIDATE-MISSING "VALIDATION_TYPE=script but $vname does not exist"
    else
      [[ -x $vfile ]] || emit "$vfile" "" L-VALIDATE-EXEC "$vname is not executable (contract §9)"
      has_failpath "$vfile" "$gdir" ||
        emit "$vfile" "" L-VALIDATE-FAILPATH "no failure path found (no 'exit N'/'return N' with N>0 and no trailing validate_* helper call)"
    fi
  fi

  if [[ -f $ldir/sandbox.sh ]]; then
    toplevel_findings "$ldir/sandbox.sh" L-SBX-TOPLEVEL
    forbidden_findings "$ldir/sandbox.sh" L-SBX-FORBIDDEN
  fi
}

TOTAL_FINDINGS=0
GAMES_CHECKED=0
GAMES_WITH_FINDINGS=0

# lint_game <game name>
lint_game() {
  local game=$1 gdir=$GAMES_DIR/$1 play=$GAMES_DIR/$1/play.sh
  local f first err entry name expected id line
  local -a files=() order=() entries=() valid=()
  local -A seen=() in_order=() dups=()

  if [[ ! -f $play ]]; then
    printf '== %s: skipped (no play.sh)\n' "$game"
    return
  fi
  GAME_FINDINGS=0
  HELPERS=()
  HELPERS_READY=0

  # 1. G-PLAY-EXEC
  [[ -x $play ]] || emit "$play" "" G-PLAY-EXEC "play.sh is not executable (contract §9)"

  # 2. G-SHEBANG and G-SYNTAX, files in sorted path order
  for f in "$gdir"/*.sh "$gdir"/levels/*/*.sh; do
    [[ -f $f ]] && files+=("$f")
  done
  if ((${#files[@]} > 0)); then
    mapfile -t files < <(printf '%s\n' "${files[@]}" | sort)
  fi
  for f in "${files[@]}"; do
    first=''
    IFS= read -r first <"$f"
    if [[ $first != '#!'* || $first != *bash* ]]; then
      emit "$f" 1 G-SHEBANG "missing bash shebang on line 1 (contract §9)"
    fi
    if ! err=$(BASH_ENV='' bash --norc --noprofile -n "$f" 2>&1 >/dev/null); then
      first=${err%%$'\n'*}
      rel "$f"
      first=${first//"$f"/"$REL"}
      emit "$f" "" G-SYNTAX "bash -n failed: $first"
    fi
  done

  # 3. G-ORDER-*
  mapfile -t order < <(awk '/^[[:space:]]*LEVEL_ORDER=\(/{f=1} f{print} f && /\)/{exit}' "$play" |
    sed -e 's/#.*$//' -e 's/^[[:space:]]*LEVEL_ORDER=(//' -e 's/).*$//' |
    tr -s ' \t' '\n\n' | tr -d "\"'" | sed '/^$/d')
  if ((${#order[@]} == 0)); then
    emit "$play" "" G-ORDER-PARSE "no LEVEL_ORDER=( ... ) array found"
  fi
  for id in "${order[@]}"; do
    if [[ $id =~ $TOKEN_RE ]]; then
      if [[ -n ${seen[$id]+x} ]]; then
        dups[$id]=1
      else
        seen[$id]=1
        in_order[$id]=1
        valid+=("$id")
      fi
    else
      line=$(order_line "$play" "$id" 1)
      emit "$play" "$line" G-ORDER-PARSE "invalid LEVEL_ORDER token '$id' (must match ^[a-zA-Z0-9_]+\$)"
    fi
  done
  for id in "${valid[@]}"; do
    if [[ -n ${dups[$id]+x} ]]; then
      line=$(order_line "$play" "$id" 2)
      emit "$play" "$line" G-ORDER-DUP "LEVEL_ORDER lists '$id' more than once"
    fi
  done
  for id in "${valid[@]}"; do
    if [[ ! -d $gdir/levels/level$id ]]; then
      line=$(order_line "$play" "$id" 1)
      emit "$play" "$line" G-ORDER-MISSING "LEVEL_ORDER lists '$id' but levels/level$id/ does not exist (contract §1)"
    fi
  done

  # 4. G-DIR-NAME, G-DIR-ORPHAN
  shopt -s dotglob
  entries=("$gdir"/levels/*)
  shopt -u dotglob
  for entry in "${entries[@]}"; do
    name=${entry##*/}
    if [[ ! -d $entry ]]; then
      emit "$entry" "" G-DIR-NAME "levels/ must contain only level<ID> directories"
    elif [[ $name == level* && ${name#level} =~ $TOKEN_RE ]]; then
      :
    else
      expected=${name#level}
      expected=${expected//[^a-zA-Z0-9_]/_}
      [[ -n $expected ]] || expected='<ID>'
      emit "$entry" "" G-DIR-NAME "levels/ entries must be directories named level<ID> (contract §1); expected levels/level$expected"
    fi
  done
  if ((${#order[@]} > 0)); then
    for entry in "${entries[@]}"; do
      name=${entry##*/}
      [[ -d $entry && $name == level* && ${name#level} =~ $TOKEN_RE ]] || continue
      id=${name#level}
      [[ -n ${in_order[$id]+x} ]] ||
        emit "$entry" "" G-DIR-ORPHAN "levels/level$id/ is not listed in LEVEL_ORDER (contract §1)"
    done
  fi

  # 5. G-COMMON-*
  for f in "$gdir"/*_common.sh; do
    [[ -f $f ]] || continue
    toplevel_findings "$f" G-COMMON-TOPLEVEL
    forbidden_findings "$f" G-COMMON-FORBIDDEN
  done

  # 6. levels, in LEVEL_ORDER order
  for id in "${valid[@]}"; do
    [[ -d $gdir/levels/level$id ]] || continue
    lint_level "$gdir" "$id"
  done

  printf '== %s: %d levels, %d findings\n' "$game" "${#order[@]}" "$GAME_FINDINGS"
  TOTAL_FINDINGS=$((TOTAL_FINDINGS + GAME_FINDINGS))
  GAMES_CHECKED=$((GAMES_CHECKED + 1))
  ((GAME_FINDINGS > 0)) && GAMES_WITH_FINDINGS=$((GAMES_WITH_FINDINGS + 1))
}

# ---------------------------------------------------------------------------
# Command line
# ---------------------------------------------------------------------------
GAMES_DIR_ARG=''
LIST_RULES=0
SHOW_HELP=0
GAME_ARGS=()

while (($# > 0)); do
  case $1 in
    -h | --help) SHOW_HELP=1 ;;
    --list-rules) LIST_RULES=1 ;;
    --games-dir)
      (($# >= 2)) || die_usage "--games-dir needs a directory"
      GAMES_DIR_ARG=$2
      shift
      ;;
    --games-dir=*) GAMES_DIR_ARG=${1#--games-dir=} ;;
    --)
      shift
      GAME_ARGS+=("$@")
      break
      ;;
    -*) die_usage "unknown option '$1'" ;;
    *) GAME_ARGS+=("$1") ;;
  esac
  shift
done

if ((SHOW_HELP)); then
  usage
  exit 0
fi
if ((LIST_RULES)); then
  for entry in "${RULES[@]}"; do
    printf '%s  %s\n' "${entry%%|*}" "${entry#*|}"
  done
  exit 0
fi

if [[ -z $GAMES_DIR_ARG ]]; then
  GAMES_DIR=$REPO_ROOT/games
else
  [[ -d $GAMES_DIR_ARG ]] || die_usage "games directory '$GAMES_DIR_ARG' does not exist"
  GAMES_DIR=$(cd "$GAMES_DIR_ARG" && pwd -P) || die_usage "cannot enter games directory '$GAMES_DIR_ARG'"
fi
[[ -d $GAMES_DIR ]] || die_usage "games directory '$GAMES_DIR' does not exist"

GAME_LIST=()
if ((${#GAME_ARGS[@]} > 0)); then
  for name in "${GAME_ARGS[@]}"; do
    if [[ -z $name || $name == */* || $name == . || $name == .. || ! -d $GAMES_DIR/$name ]]; then
      die_usage "'$name' is not a game directory under $GAMES_DIR"
    fi
    GAME_LIST+=("$name")
  done
  mapfile -t GAME_LIST < <(printf '%s\n' "${GAME_LIST[@]}" | sort -u)
else
  for entry in "$GAMES_DIR"/*/; do
    entry=${entry%/}
    GAME_LIST+=("${entry##*/}")
  done
  if ((${#GAME_LIST[@]} > 0)); then
    mapfile -t GAME_LIST < <(printf '%s\n' "${GAME_LIST[@]}" | sort)
  fi
fi

for name in "${GAME_LIST[@]}"; do
  lint_game "$name"
done

printf 'TOTAL: %d findings in %d of %d games checked\n' "$TOTAL_FINDINGS" "$GAMES_WITH_FINDINGS" "$GAMES_CHECKED"
((TOTAL_FINDINGS == 0))
exit $((TOTAL_FINDINGS > 0))
