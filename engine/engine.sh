#!/usr/bin/env bash
# CLI Academy engine (contract v2, docs/engine-contract.md).
# Sourced by games/<game>/play.sh, which defines LEVEL_ORDER and then calls: start_game "$@"
set -uo pipefail
set +e

ENGINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=ui.sh
source "$ENGINE_DIR/ui.sh"
# shellcheck source=validator.sh
source "$ENGINE_DIR/validator.sh"

# --- Paths (contract §4) -----------------------------------------------------
ENGINE_ORIG_PWD="$PWD"
GAME_DIR=""
if _engine_gd="$(cd "$(dirname -- "$0")" 2>/dev/null && pwd)"; then
  GAME_DIR="$_engine_gd"
fi
unset _engine_gd
LEVELS_DIR="$GAME_DIR/levels"
PROGRESS_FILE="$GAME_DIR/progress.log"

# --- Engine state ------------------------------------------------------------
ENGINE_MODE="play"      # play | test
ENGINE_PHASE="idle"     # idle | setup | run | validate | cleanup
_ENGINE_LEVEL_ACTIVE=0  # 1 while a level owns resources that need cleanup
_ENGINE_SETUP_CALLED=0  # 1 once setup_sandbox has been invoked for the active level
_ENGINE_SETUP_FAILED=0  # set by the ERR trap while setup_sandbox runs (contract §10)
_ENGINE_SETUP_FAILED_CMD=""
_ENGINE_SANDBOX=""
_ENGINE_TMPFILE=""
_ENGINE_LEVEL=""

_engine_restore_opts() {
  set +e
  set -u
  set -o pipefail
}

# --- Cleanup and traps (contract §2) -----------------------------------------
_engine_cleanup_level() {
  [[ "$_ENGINE_LEVEL_ACTIVE" -eq 1 ]] || return 0
  _ENGINE_LEVEL_ACTIVE=0
  trap '' INT TERM
  trap - ERR
  set +E
  ENGINE_PHASE="cleanup"
  if [[ "$_ENGINE_SETUP_CALLED" -eq 1 ]] && declare -F cleanup_sandbox >/dev/null; then
    ( cleanup_sandbox )
    local _e_rc=$?
    if [[ $_e_rc -ne 0 ]]; then
      msg_warn "cleanup_sandbox for level ${_ENGINE_LEVEL} exited with status $_e_rc"
    fi
  fi
  unset -f setup_sandbox cleanup_sandbox
  cd "$ENGINE_ORIG_PWD" 2>/dev/null || cd / || true
  if [[ -n "$_ENGINE_SANDBOX" && -d "$_ENGINE_SANDBOX" ]]; then
    rm -rf -- "$_ENGINE_SANDBOX"
  fi
  if [[ -n "$_ENGINE_TMPFILE" ]]; then
    rm -f -- "$_ENGINE_TMPFILE"
  fi
  _ENGINE_SANDBOX=""
  _ENGINE_TMPFILE=""
  _ENGINE_SETUP_CALLED=0
  ENGINE_PHASE="idle"
  trap '_engine_on_signal INT' INT
  trap '_engine_on_signal TERM' TERM
}

_engine_on_exit() {
  local rc=$?
  if [[ "$ENGINE_PHASE" == "setup" && $rc -ne 0 && $rc -ne 2 ]]; then
    msg_fail "Setup of level ${_ENGINE_LEVEL} aborted (status $rc)."
    rc=2
  fi
  _engine_cleanup_level
  exit "$rc"
}

_engine_on_signal() {
  local sig="$1"
  echo ""
  msg_warn "Interrupted. Cleaning up..."
  _engine_cleanup_level
  if [[ "$sig" == "INT" ]]; then exit 130; fi
  exit 143
}

_engine_install_traps() {
  trap _engine_on_exit EXIT
  trap '_engine_on_signal INT' INT
  trap '_engine_on_signal TERM' TERM
}

_engine_setup_error() {
  msg_fail "Setup error: $1"
  ENGINE_PHASE="idle"
  exit 2
}

# --- Progress (contract §5) --------------------------------------------------
_engine_progress_key() { printf 'level%s=completed' "$1"; }

_engine_is_completed() {
  [[ -f "$PROGRESS_FILE" ]] && grep -qxF "$(_engine_progress_key "$1")" "$PROGRESS_FILE"
}

_engine_mark_completed() {
  _engine_is_completed "$1" && return 0
  printf 'level%s=completed\n' "$1" >> "$PROGRESS_FILE"
}

_engine_count_completed() {
  local n=0 id
  for id in "${LEVEL_ORDER[@]}"; do
    if _engine_is_completed "$id"; then n=$((n + 1)); fi
  done
  echo "$n"
}

# --- Level loading -----------------------------------------------------------
_engine_valid_id() { [[ "$1" =~ ^[a-zA-Z0-9_]+$ ]]; }

_engine_require_level() {
  local id="$1"
  if ! _engine_valid_id "$id"; then
    msg_fail "Invalid level id: $id"
    exit 2
  fi
  if [[ ! -d "$LEVELS_DIR/level$id" ]]; then
    msg_fail "Level $id does not exist ($LEVELS_DIR/level$id)."
    exit 2
  fi
}

_engine_reset_level_vars() {
  NAME="" TIER="" TOOL_CMD="" VALIDATION_TYPE="" VALIDATION_SCRIPT="" VALIDATION_COMMAND=""
  EXPECTED_FILE="" EXPECTED_CONTENT=""
  FAIL_MSG="Mission failed! Try again."
  PASS_MSG="Mission accomplished!"
  # shellcheck disable=SC2034  # read by validate_content in validator.sh
  MUST_CONTAIN=()
  # shellcheck disable=SC2034  # read by validate_content in validator.sh
  MUST_NOT_CONTAIN=()
  unset -f setup_sandbox cleanup_sandbox
}

# Loads level.conf into globals and checks it. Exits 2 on any problem.
_engine_load_level() {
  LEVEL_ID="$1"
  LEVEL_DIR="$LEVELS_DIR/level$1"
  _engine_reset_level_vars
  if [[ ! -d "$LEVEL_DIR" ]]; then _engine_setup_error "level directory not found: $LEVEL_DIR"; fi
  if [[ ! -r "$LEVEL_DIR/level.conf" ]]; then _engine_setup_error "cannot read $LEVEL_DIR/level.conf"; fi
  # shellcheck source=/dev/null
  source "$LEVEL_DIR/level.conf"
  local _e_rc=$?
  _engine_restore_opts
  if [[ $_e_rc -ne 0 ]]; then _engine_setup_error "$LEVEL_DIR/level.conf failed (status $_e_rc)"; fi
  if [[ -z "$TOOL_CMD" ]]; then _engine_setup_error "TOOL_CMD is not set in $LEVEL_DIR/level.conf"; fi
  case "$VALIDATION_TYPE" in
    content_check|file_exists|diff_check) ;;
    command_check)
      if [[ -z "$VALIDATION_COMMAND" ]]; then _engine_setup_error "VALIDATION_COMMAND is not set in $LEVEL_DIR/level.conf"; fi ;;
    script)
      if [[ ! -f "$LEVEL_DIR/${VALIDATION_SCRIPT:-validate.sh}" ]]; then
        _engine_setup_error "validator not found: $LEVEL_DIR/${VALIDATION_SCRIPT:-validate.sh}"
      fi ;;
    "") _engine_setup_error "VALIDATION_TYPE is not set in $LEVEL_DIR/level.conf" ;;
    *) _engine_setup_error "unknown VALIDATION_TYPE '$VALIDATION_TYPE' in $LEVEL_DIR/level.conf" ;;
  esac
}

_engine_level_name() {
  # shellcheck source=/dev/null
  ( NAME=""; source "$LEVELS_DIR/level$1/level.conf" >/dev/null 2>&1; printf '%s' "${NAME:-}" )
}

# --- Validation (contract §8) ------------------------------------------------
_engine_validate() {
  case "$VALIDATION_TYPE" in
    content_check) validate_content "$TMP_FILE" ;;
    file_exists)   validate_file_exists "$EXPECTED_FILE" "$EXPECTED_CONTENT" ;;
    diff_check)    validate_diff "$EXPECTED_FILE" "$TMP_FILE" ;;
    command_check) validate_command "$VALIDATION_COMMAND" ;;
    script)        validate_script "$LEVEL_DIR/${VALIDATION_SCRIPT:-validate.sh}" "$TMP_FILE" ;;
    *)             return 1 ;;
  esac
}

# --- One level ---------------------------------------------------------------
# run_level <ID> [<absolute path to solution.sh>]
# Play mode when ENGINE_MODE=play, test mode when ENGINE_MODE=test.
# Returns 0 on pass, 1 on fail. Exits 2 on any setup error (the EXIT trap cleans up).
run_level() {
  local _e_id="$1"
  local _e_solution="${2:-}"
  local _e_rc=0
  local _e_result=1
  _ENGINE_LEVEL="$_e_id"
  ENGINE_PHASE="setup"
  _engine_load_level "$_e_id"

  if [[ "$ENGINE_MODE" == "play" ]]; then
    ui_level_header "$_e_id" "$NAME" "$TIER"
  fi

  # §2 step 1: engine-owned sandbox dir; mark the level active before anything else can fail
  _ENGINE_SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/cliacademy.XXXXXX")" || _engine_setup_error "mktemp -d failed"
  _ENGINE_LEVEL_ACTIVE=1
  _ENGINE_TMPFILE="$(mktemp "${TMPDIR:-/tmp}/cliacademy-task.XXXXXX")" || _engine_setup_error "mktemp failed"
  cd "$_ENGINE_SANDBOX" || _engine_setup_error "cannot cd into $_ENGINE_SANDBOX"
  # §2 step 2-3: exports and TMP_FILE
  SANDBOX_DIR="$_ENGINE_SANDBOX"
  TMP_FILE="$_ENGINE_TMPFILE"
  export SANDBOX_DIR LEVEL_ID GAME_DIR LEVEL_DIR TMP_FILE
  if [[ -f "$LEVEL_DIR/template.txt" ]]; then
    cp "$LEVEL_DIR/template.txt" "$TMP_FILE" || _engine_setup_error "cannot copy template.txt"
  fi

  # §2 step 4: sandbox.sh
  if [[ -f "$LEVEL_DIR/sandbox.sh" ]]; then
    # shellcheck source=/dev/null
    source "$LEVEL_DIR/sandbox.sh"
    _e_rc=$?
    _engine_restore_opts
    if [[ $_e_rc -ne 0 ]]; then _engine_setup_error "sourcing $LEVEL_DIR/sandbox.sh failed (status $_e_rc)"; fi
    if declare -F setup_sandbox >/dev/null; then
      _ENGINE_SETUP_CALLED=1
      _ENGINE_SETUP_FAILED=0
      _ENGINE_SETUP_FAILED_CMD=""
      # Contract §10: a failing command inside setup_sandbox is a setup error. set -E makes the
      # ERR trap fire inside the function; the trap only records the failure, it never aborts.
      # The trap is installed after the option restore above and removed before the next one.
      trap '_ENGINE_SETUP_FAILED=1; _ENGINE_SETUP_FAILED_CMD="${_ENGINE_SETUP_FAILED_CMD:-$BASH_COMMAND}"' ERR
      set -E
      setup_sandbox
      _e_rc=$?
      trap - ERR
      set +E
      _engine_restore_opts
      if [[ $_e_rc -ne 0 ]]; then _engine_setup_error "setup_sandbox for level $_e_id failed (status $_e_rc)"; fi
      if [[ $_ENGINE_SETUP_FAILED -ne 0 ]]; then
        _engine_setup_error "a command in setup_sandbox for level $_e_id failed: $_ENGINE_SETUP_FAILED_CMD"
      fi
    fi
  fi
  # Contract §10: the tool and the validator always run with cwd = SANDBOX_DIR, whatever level code did.
  cd "$_ENGINE_SANDBOX" || _engine_setup_error "cannot cd into $_ENGINE_SANDBOX after setup"

  # §2 step 5: tool or solution; exit status ignored (contract §3, §7)
  ENGINE_PHASE="run"
  if [[ "$ENGINE_MODE" == "test" ]]; then
    bash "$_e_solution" "$TMP_FILE" </dev/null
  else
    if [[ -f "$LEVEL_DIR/template.txt" ]]; then
      cat "$LEVEL_DIR/template.txt"
      echo ""
    fi
    eval "$TOOL_CMD"
  fi
  _engine_restore_opts

  # §2 step 6: validate (back in SANDBOX_DIR; if the player removed it, the level cannot pass)
  ENGINE_PHASE="validate"
  if cd "$_ENGINE_SANDBOX" 2>/dev/null; then
    if _engine_validate; then _e_result=0; fi
    _engine_restore_opts
  else
    msg_warn "Sandbox directory $_ENGINE_SANDBOX no longer exists; cannot validate."
  fi

  if [[ $_e_result -eq 0 ]]; then
    msg_success "$PASS_MSG"
    if [[ "$ENGINE_MODE" == "play" ]]; then _engine_mark_completed "$_e_id"; fi
  else
    msg_fail "$FAIL_MSG"
    if [[ "$ENGINE_MODE" == "play" ]]; then show_hint_tip "$_e_id"; fi
  fi

  # §2 step 7
  _engine_cleanup_level
  return "$_e_result"
}

# --- Commands (contract §6) --------------------------------------------------
_engine_status() {
  local id mark name
  for id in "${LEVEL_ORDER[@]}"; do
    mark="[ ]"
    if _engine_is_completed "$id"; then mark="[x]"; fi
    name="$(_engine_level_name "$id")"
    printf '  %s %-16s %s\n' "$mark" "$id" "$name"
  done
  ui_progress "$(_engine_count_completed)" "${#LEVEL_ORDER[@]}"
}

_engine_play_loop() {
  ui_progress "$(_engine_count_completed)" "${#LEVEL_ORDER[@]}"
  local _e_id _e_next
  while true; do
    _e_next=""
    for _e_id in "${LEVEL_ORDER[@]}"; do
      if ! _engine_is_completed "$_e_id"; then _e_next="$_e_id"; break; fi
    done
    if [[ -z "$_e_next" ]]; then
      banner "Congratulations! You finished all available levels!"
      msg_info "If you want to start again, type './play.sh reset'"
      exit 0
    fi
    run_level "$_e_next"
    if ! ui_continue_prompt; then
      msg_info "See you next time! Exiting..."
      exit 0
    fi
  done
}

_engine_usage_error() {
  ui_usage
  exit 2
}

start_game() {
  _engine_install_traps
  if [[ -z "$GAME_DIR" || ! -d "$LEVELS_DIR" ]]; then
    msg_fail "Cannot find the levels directory next to '$0'. Run play.sh as a program, not with 'source'."
    exit 2
  fi
  if [[ -z "${LEVEL_ORDER+x}" || ${#LEVEL_ORDER[@]} -eq 0 ]]; then
    msg_fail "LEVEL_ORDER is not defined by $0."
    exit 2
  fi

  local cmd="${1:-}"
  case "$cmd" in
    "")
      [[ $# -le 1 ]] || _engine_usage_error
      _engine_play_loop ;;
    reset)
      [[ $# -eq 1 ]] || _engine_usage_error
      msg_warn "Resetting your game progress..."
      rm -f "$PROGRESS_FILE"
      msg_success "Progress has been reset! Start again from the beginning."
      exit 0 ;;
    replay)
      [[ $# -eq 2 ]] || _engine_usage_error
      _engine_require_level "$2"
      msg_info "Replaying Level $2..."
      run_level "$2"
      exit $? ;;
    hint)
      [[ $# -eq 2 ]] || _engine_usage_error
      _engine_require_level "$2"
      if [[ -f "$LEVELS_DIR/level$2/hint.txt" ]]; then
        banner "Hint for Level $2"
        cat "$LEVELS_DIR/level$2/hint.txt"
        echo ""
        exit 0
      fi
      msg_fail "No hint available for Level $2."
      exit 1 ;;
    status)
      [[ $# -eq 1 ]] || _engine_usage_error
      _engine_status
      exit 0 ;;
    help|-h|--help)
      ui_usage
      exit 0 ;;
    test)
      [[ $# -eq 3 ]] || _engine_usage_error
      _engine_require_level "$2"
      local _e_solution="$3"
      if [[ "$_e_solution" != /* ]]; then _e_solution="$ENGINE_ORIG_PWD/$_e_solution"; fi
      if [[ ! -f "$_e_solution" || ! -r "$_e_solution" ]]; then
        msg_fail "Solution script not found or not readable: $3"
        exit 2
      fi
      ENGINE_MODE="test"
      run_level "$2" "$_e_solution"
      exit $? ;;
    *)
      msg_fail "Unknown command: $cmd"
      _engine_usage_error ;;
  esac
}
