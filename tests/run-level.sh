#!/usr/bin/env bash
# run-level.sh - run ONE level of a CLI Academy game with a scripted player
# (a "solution script") and report a verdict. See tests/README.md.
set -uo pipefail
export LC_ALL=C

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib/harness.sh
source "$SELF_DIR/lib/harness.sh"
REPO_ROOT="$(harness_repo_root)"

usage() {
  cat <<'USAGE_EOF'
Usage: tests/run-level.sh [options] <game> <ID> <solution.sh>

Runs level <ID> of <game> with the scripted player <solution.sh> and prints a
final line:  RESULT <VERDICT> <game> <ID> <solution> rc=<rc> secs=<n> mode=<mode>

Options:
  --legacy             drive today's interactive engine through stdin (temporary)
  --timeout <s>        integer 1-600; overrides the "# timeout: N" solution header
                       (default 30)
  --log <file>         write the full engine output, with a header, to <file>
  --quiet              print only the RESULT line
  --verbose            print the engine output even on PASS
  --keep               keep the run directory (printed as "kept: <dir>" on stderr)
  --games-dir <dir>    where <game>/ lives (default: <repo>/games)
  --no-msg-check       skip the PASS_MSG/FAIL_MSG check
  -h, --help           print this help and exit 0

Environment:
  CLI_ACADEMY_TEST_GITCONFIG=<file>   copied to the run's $HOME/.gitconfig

Exit status = verdict: PASS 0, FAIL 1, ERROR 2, TIMEOUT 3, CRASH 4, LEAK 5.
A usage error also exits 2 (without a RESULT line).
USAGE_EOF
}

# ---------------------------------------------------------------- state ----
legacy=0
timeout_set=0
timeout_arg=""
log_arg=""
quiet=0
verbose=0
keep=0
games_dir_arg=""
msg_check=1

GAME=""
ID=""
SOL_ARG=""
SOL_BASE=""
SOL=""
MODE="contract"
GAMES_DIR=""
T=30
RUN_TMP=""
LOG=""
BODY=""
CHILD=""
CLEANED=0
LEAKED_SERVERS=()
ENV_VARS=()

# ------------------------------------------------------------- helpers ----
usage_error() {
  printf 'run-level: %s\n' "$1" >&2
  usage >&2
  exit 2
}

result_line() { # verdict rc secs note
  local line
  line="RESULT $1 $GAME $ID $SOL_BASE rc=$2 secs=$3 mode=$MODE"
  if [[ -n $4 ]]; then
    line+=" note=${4//$'\n'/ }"
  fi
  printf '%s\n' "$line"
}

input_error() {
  printf 'run-level: %s\n' "$1" >&2
  result_line ERROR - 0 "$1"
  exit 2
}

valid_timeout() { # prints the normalised decimal value, returns 1 if invalid
  local v=$1
  [[ $v =~ ^[0-9]+$ ]] || return 1
  (( ${#v} <= 4 )) || return 1
  v=$((10#$v))
  (( v >= 1 && v <= 600 )) || return 1
  printf '%s' "$v"
}

# Kill (politely, then hard) the engine process tree started by this script.
kill_engine() {
  local pid="" i
  [[ -n $CHILD ]] || return 0
  kill -0 "$CHILD" 2>/dev/null || return 0
  if [[ -r $RUN_TMP/engine.pid ]]; then
    pid="$(<"$RUN_TMP/engine.pid")"
  fi
  if [[ $pid =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
    kill -TERM "$pid" 2>/dev/null
  else
    kill -TERM "$CHILD" 2>/dev/null
  fi
  for ((i = 0; i < 80; i++)); do
    kill -0 "$CHILD" 2>/dev/null || return 0
    sleep 0.1
  done
  if [[ $pid =~ ^[0-9]+$ ]]; then kill -KILL "$pid" 2>/dev/null; fi
  kill -KILL "$CHILD" 2>/dev/null
  return 0
} 2>/dev/null   # silences bash's "Killed" job notice

# Kill every tmux server whose socket lives under $RUN_TMP/tmux; remember the
# names of the ones that were still alive in LEAKED_SERVERS.
reap_tmux_servers() {
  local sock
  command -v tmux >/dev/null 2>&1 || return 0
  [[ -n $RUN_TMP && -d $RUN_TMP/tmux ]] || return 0
  while IFS= read -r sock; do
    [[ -n $sock ]] || continue
    if timeout 5 tmux -S "$sock" list-sessions >/dev/null 2>&1; then
      LEAKED_SERVERS+=("${sock##*/}")
      timeout 5 tmux -S "$sock" kill-server >/dev/null 2>&1
    fi
  done < <(find "$RUN_TMP/tmux" -type s 2>/dev/null | sort)
  return 0
}

cleanup() {
  if (( CLEANED )); then return 0; fi
  CLEANED=1
  kill_engine
  if [[ -n $RUN_TMP && -d $RUN_TMP ]]; then
    reap_tmux_servers
    if (( keep )); then
      printf 'kept: %s\n' "$RUN_TMP" >&2
    else
      rm -rf "$RUN_TMP"
    fi
  fi
  return 0
}

on_signal() { # signal name: clean up, then die from that signal
  cleanup
  trap - EXIT INT TERM HUP
  kill -s "$1" "$$"
  exit 1
}

trap cleanup EXIT
trap 'on_signal INT' INT
trap 'on_signal TERM' TERM
trap 'on_signal HUP' HUP

# ---------------------------------------------------- argument parsing ----
args=()
while (( $# > 0 )); do
  case $1 in
    --legacy) legacy=1 ;;
    --timeout)
      (( $# >= 2 )) || usage_error "--timeout needs a value"
      timeout_set=1
      timeout_arg=$2
      shift
      ;;
    --log)
      (( $# >= 2 )) || usage_error "--log needs a file"
      log_arg=$2
      shift
      ;;
    --quiet) quiet=1 ;;
    --verbose) verbose=1 ;;
    --keep) keep=1 ;;
    --games-dir)
      (( $# >= 2 )) || usage_error "--games-dir needs a directory"
      games_dir_arg=$2
      shift
      ;;
    --no-msg-check) msg_check=0 ;;
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

(( ${#args[@]} == 3 )) || usage_error "expected 3 arguments (<game> <ID> <solution.sh>), got ${#args[@]}"
GAME=${args[0]}
ID=${args[1]}
SOL_ARG=${args[2]}
SOL_BASE=${SOL_ARG##*/}
if (( legacy )); then MODE="legacy"; fi
GAMES_DIR=${games_dir_arg:-$REPO_ROOT/games}

# ---------------------------------------------------- input validation ----
if [[ ! $GAME =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ || ! -f $GAMES_DIR/$GAME/play.sh ]]; then
  input_error "unknown game '$GAME' ($GAMES_DIR/$GAME/play.sh not found)"
fi
GAMES_DIR="$(cd "$GAMES_DIR" && pwd)"

if [[ ! $ID =~ ^[a-zA-Z0-9_]+$ ]]; then
  input_error "invalid level ID '$ID' (must match ^[a-zA-Z0-9_]+\$)"
fi

if [[ ! -f $SOL_ARG || ! -r $SOL_ARG ]]; then
  input_error "solution not found or not readable: $SOL_ARG"
fi
SOL="$(cd "$(dirname -- "$SOL_ARG")" && pwd)/$(basename -- "$SOL_ARG")"

if (( timeout_set )); then
  tvalue=$timeout_arg
  tsource="--timeout"
else
  tvalue="$(sed -n '1,10s/^# timeout: \([0-9][0-9]*\)$/\1/p' "$SOL" | head -n 1)"
  tsource="solution header"
  if [[ -z $tvalue ]]; then tvalue=30; fi
fi
if ! T="$(valid_timeout "$tvalue")"; then
  input_error "bad timeout '$tvalue' from $tsource (must be an integer 1-600)"
fi

gitconfig="${CLI_ACADEMY_TEST_GITCONFIG:-}"
if [[ -n $gitconfig && ( ! -f $gitconfig || ! -r $gitconfig ) ]]; then
  input_error "CLI_ACADEMY_TEST_GITCONFIG is not a readable file: $gitconfig"
fi

command -v timeout >/dev/null 2>&1 || input_error "required command not found: timeout (GNU coreutils)"

# ------------------------------------------------ run directory and env ----
RUN_TMP="$(mktemp -d /tmp/cla.XXXXXXXX)" || input_error "cannot create a run directory under /tmp"
if ! mkdir "$RUN_TMP/home" "$RUN_TMP/tmp" "$RUN_TMP/tmux" "$RUN_TMP/cwd"; then
  input_error "cannot create the run directories in $RUN_TMP"
fi
if [[ -n $gitconfig ]]; then
  cp -- "$gitconfig" "$RUN_TMP/home/.gitconfig" || input_error "cannot copy $gitconfig"
fi

run_user="$(id -un 2>/dev/null)" || run_user="${USER:-user}"
bash_path="$(command -v bash)"
ENV_VARS=(
  "PATH=${PATH:-/usr/local/bin:/usr/bin:/bin}"
  "HOME=$RUN_TMP/home"
  "USER=$run_user"
  "LOGNAME=$run_user"
  "SHELL=$bash_path"
  "TERM=xterm-256color"
  "LANG=C"
  "LC_ALL=C"
  "TMPDIR=$RUN_TMP/tmp"
  "TMUX_TMPDIR=$RUN_TMP/tmux"
  "GIT_CONFIG_NOSYSTEM=1"
  "GIT_TERMINAL_PROMPT=0"
  "GIT_EDITOR=true"
  "EDITOR=true"
  "VISUAL=true"
  "PAGER=cat"
  "GIT_PAGER=cat"
)

if [[ -n $log_arg ]]; then
  case $log_arg in
    /*) LOG=$log_arg ;;
    *) LOG="$PWD/$log_arg" ;;
  esac
  mkdir -p "$(dirname "$LOG")" 2>/dev/null || input_error "cannot create the directory for --log $log_arg"
else
  LOG="$RUN_TMP/run.log"
fi
BODY="$RUN_TMP/engine-output.txt"
printf '# run-level game=%s id=%s solution=%s mode=%s timeout=%ss\n' \
  "$GAME" "$ID" "$SOL" "$MODE" "$T" >"$LOG" || input_error "cannot write the log file $LOG"

# ------------------------------------------------------ engine runners ----
# Both runners execute in a background subshell; they record their own PID
# (which becomes the PID of `timeout` after exec) so a signal handler can stop
# the engine before the run directory is removed.
run_engine_contract() {
  cd "$RUN_TMP/cwd" || exit 97
  printf '%s' "$BASHPID" >"$RUN_TMP/engine.pid"
  exec env -i "${ENV_VARS[@]}" timeout -k 5 "$T" \
    "$GAMES_DIR/$GAME/play.sh" test "$ID" "$SOL" </dev/null
}

run_engine_legacy() {
  cd "$RUN_TMP/legacy/games/$GAME" || exit 97
  printf 'bash %q </dev/null\nexit\nn\n' "$SOL" |
    {
      printf '%s' "$BASHPID" >"$RUN_TMP/engine.pid"
      exec env -i "${ENV_VARS[@]}" timeout -k 5 "$T" ./play.sh replay "$ID"
    }
  exit "${PIPESTATUS[1]}"
}

progress_state() { # cksum of the game's progress.log, or the word "absent"
  local f="$GAMES_DIR/$GAME/progress.log"
  if [[ -e $f ]]; then cksum "$f"; else printf 'absent'; fi
}

if (( legacy )); then
  mkdir -p "$RUN_TMP/legacy/games" || input_error "cannot create the legacy run tree"
  cp -R "$REPO_ROOT/engine" "$RUN_TMP/legacy/engine" || input_error "cannot copy engine/ for legacy mode"
  cp -R "$GAMES_DIR/$GAME" "$RUN_TMP/legacy/games/$GAME" || input_error "cannot copy the game for legacy mode"
  rm -f "$RUN_TMP/legacy/games/$GAME/progress.log"
else
  progress_before="$(progress_state)"
fi

start=$SECONDS
if (( legacy )); then
  run_engine_legacy >>"$LOG" 2>&1 &
else
  run_engine_contract >>"$LOG" 2>&1 &
fi
CHILD=$!
# (stderr silenced: bash would otherwise print a "Killed" notice when timeout -k fires)
wait "$CHILD" 2>/dev/null
rc=$?
secs=$((SECONDS - start))
CHILD=""

tail -n +2 "$LOG" >"$BODY" 2>/dev/null || : >"$BODY"

# ------------------------------------------------------------ verdicts ----
verdict=1
note=""

join_by() { # separator item...
  local sep=$1 out="" first=1 item
  shift
  for item in "$@"; do
    if (( first )); then out=$item; first=0; else out+="$sep$item"; fi
  done
  printf '%s' "$out"
}

decide_legacy() {
  reap_tmux_servers
  if (( rc == 124 || rc == 137 )); then
    verdict=3
  elif grep -q '^\[PASS\] ' "$BODY"; then
    verdict=0
  else
    verdict=1
  fi
  if (( ${#LEAKED_SERVERS[@]} > 0 )); then
    local s notes=()
    for s in "${LEAKED_SERVERS[@]}"; do
      notes+=("tmux server $s still running (killed)")
    done
    note="$(join_by '; ' "${notes[@]}")"
  fi
}

decide_contract() {
  local progress_after var msg
  if (( rc == 124 || rc == 137 )); then verdict=3; return 0; fi
  if (( rc == 2 )); then verdict=2; return 0; fi
  if (( rc != 0 && rc != 1 )); then
    verdict=4
    note="engine exit $rc"
    return 0
  fi
  progress_after="$(progress_state)"
  if [[ $progress_after != "$progress_before" ]]; then
    verdict=4
    note="test mode wrote progress.log"
    return 0
  fi
  if (( msg_check )); then
    var=PASS_MSG
    if (( rc == 1 )); then var=FAIL_MSG; fi
    msg=""
    msg="$(harness_conf_get "$GAMES_DIR/$GAME/levels/level$ID/level.conf" "$var")" || msg=""
    if [[ -n $msg ]] && ! grep -qF -- "$msg" "$BODY"; then
      verdict=4
      note="engine exited $rc without printing $var"
      return 0
    fi
  fi

  # Leak check: anything left in the private TMPDIR, any tmux server still alive.
  local notes=() names=() p count=0
  while IFS= read -r p; do
    [[ -n $p ]] || continue
    count=$((count + 1))
    if (( count <= 5 )); then names+=("${p##*/}"); fi
  done < <(find "$RUN_TMP/tmp" -mindepth 1 -maxdepth 1 2>/dev/null | sort)
  if (( count > 0 )); then
    notes+=("left in TMPDIR: $(join_by ', ' "${names[@]}")")
  fi
  reap_tmux_servers
  local s
  for s in "${LEAKED_SERVERS[@]+"${LEAKED_SERVERS[@]}"}"; do
    notes+=("tmux server $s still running")
  done
  if (( ${#notes[@]} > 0 )); then
    verdict=5
    note="$(join_by '; ' "${notes[@]}")"
    return 0
  fi

  verdict=$rc
  return 0
}

if (( legacy )); then decide_legacy; else decide_contract; fi
verdict_name="$(harness_verdict_name "$verdict")"

# -------------------------------------------------------------- output ----
if (( ! quiet )) && [[ $verdict_name != PASS || $verbose -eq 1 ]]; then
  awk '{ print "  | " $0 }' "$BODY"
fi

cleanup
result_line "$verdict_name" "$rc" "$secs" "$note"
exit "$verdict"
