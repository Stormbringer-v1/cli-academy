#!/usr/bin/env bash
# run-game.sh - run every committed solution of one game through run-level.sh,
# check that correct solutions pass and wrong ones fail, print a table, and
# exit non-zero on any mismatch. See tests/README.md.
set -uo pipefail
export LC_ALL=C

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib/harness.sh
source "$SELF_DIR/lib/harness.sh"
REPO_ROOT="$(harness_repo_root)"
RUN_LEVEL="$REPO_ROOT/tests/run-level.sh"

usage() {
  cat <<'USAGE_EOF'
Usage: tests/run-game.sh [--legacy] [--log-dir <dir>] [--only <ID>[,<ID>...]]
                         [--games-dir <dir>] [--solutions-dir <dir>] <game>

Runs <solutions-dir>/<game>/<ID>.sh for every ID in the game's LEVEL_ORDER
(expect PASS), <ID>.wrong.sh when present (expect FAIL) and honours <ID>.xfail
markers. Prints a table and exits 0 only when every row is good.

Options:
  --legacy              pass --legacy to run-level.sh (temporary interim mode)
  --log-dir <dir>       where the per-run logs go (default: a new /tmp/cla-logs.*)
  --only <ID>[,<ID>..]  only these levels (still in LEVEL_ORDER order; skips the orphan check)
  --games-dir <dir>     where <game>/ lives (default: <repo>/games)
  --solutions-dir <dir> where <game>/<ID>.sh live (default: <repo>/tests/solutions)
  -h, --help            print this help and exit 0

Exit status: 0 all rows good, 1 at least one bad row, 2 usage or setup error.
USAGE_EOF
}

die() { # exit 2 with a message
  printf 'run-game: %s\n' "$1" >&2
  exit 2
}

usage_error() {
  printf 'run-game: %s\n' "$1" >&2
  usage >&2
  exit 2
}

# ---------------------------------------------------- argument parsing ----
legacy=0
log_dir=""
only_arg=""
only_set=0
games_dir="$REPO_ROOT/games"
solutions_dir="$REPO_ROOT/tests/solutions"
args=()
while (( $# > 0 )); do
  case $1 in
    --legacy) legacy=1 ;;
    --log-dir)
      (( $# >= 2 )) || usage_error "--log-dir needs a directory"
      log_dir=$2
      shift
      ;;
    --only)
      (( $# >= 2 )) || usage_error "--only needs a list of IDs"
      only_arg=$2
      only_set=1
      shift
      ;;
    --games-dir)
      (( $# >= 2 )) || usage_error "--games-dir needs a directory"
      games_dir=$2
      shift
      ;;
    --solutions-dir)
      (( $# >= 2 )) || usage_error "--solutions-dir needs a directory"
      solutions_dir=$2
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      while (( $# > 0 )); do
        args+=("$1")
        shift
      done
      break
      ;;
    -*) usage_error "unknown option: $1" ;;
    *) args+=("$1") ;;
  esac
  shift
done
(( ${#args[@]} == 1 )) || usage_error "expected exactly one <game> argument, got ${#args[@]}"
game=${args[0]}
if (( legacy )); then mode="legacy"; else mode="contract"; fi

# ------------------------------------------------------ preconditions ----
[[ -f $games_dir/$game/play.sh ]] || die "unknown game '$game': $games_dir/$game/play.sh not found"
games_dir="$(cd "$games_dir" && pwd)"
sol_dir="$solutions_dir/$game"
[[ -d $sol_dir ]] || die "no solutions directory: $sol_dir"
sol_dir="$(cd "$sol_dir" && pwd)"

all_ids=()
while IFS= read -r line; do
  all_ids+=("$line")
done < <(harness_level_order "$games_dir/$game/play.sh")
(( ${#all_ids[@]} > 0 )) || die "LEVEL_ORDER is empty in $games_dir/$game/play.sh"

declare -A in_order=()
for id in "${all_ids[@]}"; do in_order[$id]=1; done

declare -A wanted=()
if (( only_set )); then
  only_count=0
  IFS=',' read -r -a only_ids <<<"$only_arg"
  for id in "${only_ids[@]}"; do
    [[ -n $id ]] || continue
    [[ -n ${in_order[$id]+x} ]] || die "--only: '$id' is not in LEVEL_ORDER of $game"
    wanted[$id]=1
    only_count=$((only_count + 1))
  done
  (( only_count > 0 )) || die "--only needs at least one ID"
fi

conf="$games_dir/$game/game.conf"
if [[ -f $conf ]]; then
  dep="$(sed -n 's/^TOOL_DEPENDENCY="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' "$conf" | head -n 1)"
  if [[ -n $dep ]] && ! command -v "$dep" >/dev/null 2>&1; then
    die "$game needs '$dep' (TOOL_DEPENDENCY in game.conf), which is not installed"
  fi
fi

if [[ -z $log_dir ]]; then
  log_dir="$(mktemp -d /tmp/cla-logs.XXXXXXXX)" || die "cannot create a log directory under /tmp"
else
  mkdir -p "$log_dir" || die "cannot create the log directory: $log_dir"
fi
log_dir="$(cd "$log_dir" && pwd)"

# ------------------------------------------------------------- the run ----
n_checks=0
n_ok=0
n_bad=0
n_levels=0
n_wrong=0
n_xfail=0
n_skipped=0
bad_files=()
bad_status=()
bad_logs=()

row() { # level file expect got secs status
  printf '%-12s %-20s %-6s %-8s %5s  %s\n' "$1" "$2" "$3" "$4" "$5" "$6"
}

mark_bad() { # file status [log]
  n_bad=$((n_bad + 1))
  bad_files+=("$1")
  bad_status+=("$2")
  bad_logs+=("${3:-}")
}

# check_run <ID> <file> -> sets GOT and SECS (and LOGFILE)
check_run() {
  local id=$1 file=$2 begin rc result
  LOGFILE="$log_dir/$file.log"
  begin=$SECONDS
  if (( legacy )); then
    result="$("$RUN_LEVEL" --quiet --log "$LOGFILE" --legacy --games-dir "$games_dir" "$game" "$id" "$sol_dir/$file")"
    rc=$?
  else
    result="$("$RUN_LEVEL" --quiet --log "$LOGFILE" --games-dir "$games_dir" "$game" "$id" "$sol_dir/$file")"
    rc=$?
  fi
  SECS=$((SECONDS - begin))
  GOT="$(harness_verdict_name "$rc")"
  # Keep run-level's RESULT line (it carries the note) at the end of the log.
  if [[ -n $result && -f $LOGFILE ]]; then
    printf '# %s\n' "$result" >>"$LOGFILE"
  fi
}

row LEVEL FILE EXPECT GOT SECS STATUS

for id in "${all_ids[@]}"; do
  if (( only_set )) && [[ -z ${wanted[$id]+x} ]]; then continue; fi
  n_levels=$((n_levels + 1))
  sh_file="$id.sh"
  wrong_file="$id.wrong.sh"
  xfail_file="$id.xfail"

  if [[ ! -f $sol_dir/$sh_file ]]; then
    row "$id" "$sh_file" - - - MISSING
    mark_bad "$sh_file" MISSING
    continue
  fi

  if [[ -e $sol_dir/$xfail_file ]]; then
    if ! grep -q '[^[:space:]]' "$sol_dir/$xfail_file" 2>/dev/null; then
      row "$id" "$xfail_file" - - - BADMARK
      mark_bad "$xfail_file" BADMARK
      continue
    fi
    check_run "$id" "$sh_file"
    n_checks=$((n_checks + 1))
    n_xfail=$((n_xfail + 1))
    if [[ $GOT == PASS ]]; then
      row "$id" "$sh_file" XFAIL "$GOT" "$SECS" XPASS
      mark_bad "$sh_file" XPASS "$LOGFILE"
    else
      n_ok=$((n_ok + 1))
      row "$id" "$sh_file" XFAIL "$GOT" "$SECS" XFAIL
    fi
    if [[ -e $sol_dir/$wrong_file ]]; then
      n_skipped=$((n_skipped + 1))
      row "$id" "$wrong_file" - - - SKIP
    fi
    continue
  fi

  check_run "$id" "$sh_file"
  n_checks=$((n_checks + 1))
  if [[ $GOT == PASS ]]; then
    n_ok=$((n_ok + 1))
    row "$id" "$sh_file" PASS "$GOT" "$SECS" ok
  else
    row "$id" "$sh_file" PASS "$GOT" "$SECS" MISMATCH
    mark_bad "$sh_file" MISMATCH "$LOGFILE"
  fi

  if [[ -e $sol_dir/$wrong_file ]]; then
    check_run "$id" "$wrong_file"
    n_checks=$((n_checks + 1))
    n_wrong=$((n_wrong + 1))
    if [[ $GOT == FAIL ]]; then
      n_ok=$((n_ok + 1))
      row "$id" "$wrong_file" FAIL "$GOT" "$SECS" ok
    else
      row "$id" "$wrong_file" FAIL "$GOT" "$SECS" MISMATCH
      mark_bad "$wrong_file" MISMATCH "$LOGFILE"
    fi
  fi
done

# Orphans: anything in the solutions directory that no level owns.
if (( ! only_set )); then
  declare -A known=()
  for id in "${all_ids[@]}"; do
    known["$id.sh"]=1
    known["$id.wrong.sh"]=1
    known["$id.xfail"]=1
  done
  shopt -s nullglob dotglob
  for path in "$sol_dir"/*; do
    name=${path##*/}
    if [[ -z ${known[$name]+x} ]]; then
      row - "$name" - - - ORPHAN
      mark_bad "$name" ORPHAN
    fi
  done
  shopt -u nullglob dotglob
fi

# Details for every bad row.
for i in "${!bad_files[@]}"; do
  if [[ -n ${bad_logs[$i]} && -f ${bad_logs[$i]} ]]; then
    printf -- '---- %s: %s (log: %s)\n' "${bad_files[$i]}" "${bad_status[$i]}" "${bad_logs[$i]}"
    tail -n 40 "${bad_logs[$i]}"
  else
    printf -- '---- %s: %s (no log)\n' "${bad_files[$i]}" "${bad_status[$i]}"
  fi
done

printf 'SUMMARY %s: %d checks, %d ok, %d bad (levels=%d, wrong=%d, xfail=%d, skipped=%d) mode=%s\n' \
  "$game" "$n_checks" "$n_ok" "$n_bad" "$n_levels" "$n_wrong" "$n_xfail" "$n_skipped" "$mode"
printf 'Logs: %s\n' "$log_dir"
if (( n_bad == 0 )); then
  printf 'RESULT: PASS\n'
  exit 0
fi
printf 'RESULT: FAIL\n'
exit 1
