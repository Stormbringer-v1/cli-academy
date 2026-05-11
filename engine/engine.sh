#!/usr/bin/env bash
set -euo pipefail

# Game Engine Core
# Expected to be sourced by game-specific play.sh

# Source UI helpers
# Get directory of current script to find ui.sh
ENGINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ENGINE_DIR/ui.sh"
source "$ENGINE_DIR/validator.sh"

# Default paths
# Ensure PROGRESS_FILE is an absolute path so it can be written to even after cd'ing into TMP_DIR
PROGRESS_FILE="$(pwd)/progress.log"
LEVELS_DIR="levels"

# Check for special arguments
handle_args() {
  local arg1="${1:-}"
  local arg2="${2:-}"

  if [[ "$arg1" == "reset" ]]; then
    msg_warn "Resetting your game progress..."
    rm -f "$PROGRESS_FILE"
    touch "$PROGRESS_FILE"
    msg_success "Progress has been reset! Start again from the beginning."
    exit 0
  fi

  if [[ "$arg1" == "replay" ]]; then
    if [[ -z "$arg2" ]]; then
      echo "Usage: ./play.sh replay <level>"
      exit 1
    fi
    if [[ ! "$arg2" =~ ^[a-zA-Z0-9_]+$ ]]; then
      echo "Invalid level: $arg2"
      exit 1
    fi
    REPLAY_LEVEL="$arg2"
    if [[ ! -d "$LEVELS_DIR/level${REPLAY_LEVEL}" ]]; then
      msg_fail "Level ${REPLAY_LEVEL} does not exist."
      exit 1
    fi
    msg_info "Replaying Level ${REPLAY_LEVEL}..."
    run_level "$REPLAY_LEVEL"
    exit 0
  fi

  if [[ "$arg1" == "hint" ]]; then
    if [[ -z "$arg2" ]]; then
      echo "Usage: ./play.sh hint <level>"
      exit 1
    fi
    if [[ ! "$arg2" =~ ^[a-zA-Z0-9_]+$ ]]; then
      echo "Invalid level: $arg2"
      exit 1
    fi
    local HINT_FILE="$LEVELS_DIR/level${arg2}/hint.txt"
    if [[ -f "$HINT_FILE" ]]; then
        banner "Hint for Level ${arg2}"
        cat "$HINT_FILE"
        echo ""
    else
        msg_fail "No hint available for Level ${arg2}."
    fi
    exit 0
  fi
}

# Progress key helper
get_progress_key() {
  local lvl=$1
  if [[ "$lvl" == boss* ]]; then
    echo "${lvl}=completed"
  else
    echo "level${lvl}=completed"
  fi
}

# Run a single level
run_level() {
  local LEVEL=$1
  local LVL_DIR="$LEVELS_DIR/level$LEVEL"
  # Make LVL_DIR absolute so we can find things after cd
  local ABS_LVL_DIR="$(cd "$LVL_DIR" && pwd)"
  local CONF_FILE="$ABS_LVL_DIR/level.conf"
  local TEMPLATE="$ABS_LVL_DIR/template.txt"

  # Reset validation variables (must be reset per level)
  declare -a MUST_CONTAIN=()
  declare -a MUST_NOT_CONTAIN=()
  EXPECTED_FILE=""
  EXPECTED_CONTENT=""
  VALIDATION_TYPE="content_check"
  FAIL_MSG="Mission failed! Try again."
  PASS_MSG="Mission accomplished!"
  TOOL_CMD="vim \$TMP_FILE"
  NEEDS_DIR="false"

  # Load level config
  if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
  fi

  local TMP_FILE=""
  local TMP_DIR=""
  local ORIGINAL_PWD
  ORIGINAL_PWD="$(pwd)"
  
  if [[ "$NEEDS_DIR" == "true" ]]; then
    TMP_DIR="$(mktemp -d -t "gamedir${LEVEL}.XXXXXX")"
    cd "$TMP_DIR"
  fi

  # Support level-specific sandboxing (Section 8.3 of Master Plan)
  if [[ -f "$ABS_LVL_DIR/sandbox.sh" ]]; then
    source "$ABS_LVL_DIR/sandbox.sh"
    setup_sandbox
  fi

  TMP_FILE="$(mktemp -t "gamelevel${LEVEL}.XXXXXX")"
  # Only copy if the template exists (some tools might not need one)
  if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$TMP_FILE"
  else
    touch "$TMP_FILE"
  fi

  # Execute tool command
  # Replace literal $TMP_FILE and $TMP_DIR in TOOL_CMD
  local ACTUAL_CMD
  ACTUAL_CMD=$(echo "$TOOL_CMD" | sed "s|\$TMP_FILE|$TMP_FILE|g" | sed "s|\$TMP_DIR|$TMP_DIR|g")

  # For shell-based games (e.g. git-game, bash-game), show the level template first.
  if [[ "$TOOL_CMD" == "bash" ]] && [[ -f "$TEMPLATE" ]]; then
    echo ""
    cat "$TEMPLATE"
    echo ""
  fi
  
  # Run the command
  # echo "DEBUG: Running $ACTUAL_CMD"
  eval "$ACTUAL_CMD"

  # Perform validation based on type
  local PASSED=0
  case "$VALIDATION_TYPE" in
    "content_check")
      if validate_content "$TMP_FILE"; then PASSED=1; fi
      ;;
    "file_exists")
      if validate_file_exists "$EXPECTED_FILE" "$EXPECTED_CONTENT"; then PASSED=1; fi
      ;;
    "diff_check")
      if validate_diff "$EXPECTED_FILE" "$TMP_FILE"; then PASSED=1; fi
      ;;
    "command_check")
      if validate_command "$VALIDATION_COMMAND"; then PASSED=1; fi
      ;;
    "script")
      local SCRIPT_PATH="$ABS_LVL_DIR/validate.sh"
      if [[ -n "${VALIDATION_SCRIPT:-}" ]]; then
        SCRIPT_PATH="$ABS_LVL_DIR/$VALIDATION_SCRIPT"
      fi
      if [[ -n "${SANDBOX_DIR:-}" ]]; then
        SANDBOX_DIR="$SANDBOX_DIR" validate_script "$SCRIPT_PATH" "$TMP_FILE"
      else
        validate_script "$SCRIPT_PATH" "$TMP_FILE"
      fi
      if [[ $? -eq 0 ]]; then PASSED=1; fi
      ;;
    *)
      msg_fail "Unknown validation type: $VALIDATION_TYPE"
      ;;
  esac

  if [[ $PASSED -eq 1 ]]; then
    msg_success "$PASS_MSG"
    local KEY
    KEY=$(get_progress_key "$LEVEL")
    if ! grep -q "$KEY" "$PROGRESS_FILE" 2>/dev/null; then
        echo "$KEY" >> "$PROGRESS_FILE"
    fi
  else
    msg_fail "$FAIL_MSG"
    show_hint_tip "$LEVEL"
  fi

  # Cleanup sandbox if it exists
  if [[ "$(type -t cleanup_sandbox)" == "function" ]]; then
    cleanup_sandbox
    unset -f setup_sandbox
    unset -f cleanup_sandbox
  fi

  # Cleanup TMP_DIR if created
  if [[ -n "$TMP_DIR" ]]; then
    cd "$ORIGINAL_PWD"
    rm -rf "$TMP_DIR"
  fi
  rm -f "$TMP_FILE"

  # Continue prompt
  read -p "👉 Do you want to continue to the next level? (y/N): " CONTINUE
  if [[ ! "$CONTINUE" =~ ^[yY]$ ]]; then
    msg_info "See you next time! Exiting..."
    exit 0
  fi
}

# Main game loop
start_game() {
  handle_args "$@"

  while true; do
    FOUND=0
    for LVL in "${LEVEL_ORDER[@]}"; do
      if ! grep -q "$(get_progress_key "$LVL")" "$PROGRESS_FILE" 2>/dev/null; then
        run_level "$LVL"
        FOUND=1
        break
      fi
    done

    if [[ $FOUND -eq 0 ]]; then
      banner "Congratulations! You finished all available levels!"
      msg_info "If you want to start again, type './play.sh reset'"
      exit 0
    fi
  done
}
