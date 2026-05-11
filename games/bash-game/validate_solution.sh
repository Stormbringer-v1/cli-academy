#!/usr/bin/env bash
set -euo pipefail

validate_solution_level() {
  local solution_file="${SOLUTION_FILE:-solution.sh}"
  if [[ ! -f "$solution_file" ]]; then
    echo "solution.sh not found in current directory."
    return 1
  fi

  local pattern
  if declare -p REQUIRED_PATTERNS >/dev/null 2>&1; then
    for pattern in "${REQUIRED_PATTERNS[@]}"; do
      if ! grep -Eq "$pattern" "$solution_file"; then
        echo "Missing required pattern in solution.sh: $pattern"
        return 1
      fi
    done
  fi

  if declare -p FORBIDDEN_PATTERNS >/dev/null 2>&1; then
    for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
      if grep -Eq "$pattern" "$solution_file"; then
        echo "Forbidden pattern found in solution.sh: $pattern"
        return 1
      fi
    done
  fi

  local stdout_file stderr_file
  stdout_file="$(mktemp "/tmp/bashgame_stdout.XXXXXX")"
  stderr_file="$(mktemp "/tmp/bashgame_stderr.XXXXXX")"

  local exit_code=0
  set +e
  if declare -p SCRIPT_ARGS >/dev/null 2>&1; then
    if [[ -n "${TEST_STDIN:-}" ]]; then
      printf "%s" "$TEST_STDIN" | bash "$solution_file" "${SCRIPT_ARGS[@]}" >"$stdout_file" 2>"$stderr_file"
    else
      bash "$solution_file" "${SCRIPT_ARGS[@]}" >"$stdout_file" 2>"$stderr_file"
    fi
  else
    if [[ -n "${TEST_STDIN:-}" ]]; then
      printf "%s" "$TEST_STDIN" | bash "$solution_file" >"$stdout_file" 2>"$stderr_file"
    else
      bash "$solution_file" >"$stdout_file" 2>"$stderr_file"
    fi
  fi
  exit_code=$?
  set -e

  local expected_exit="${EXPECTED_EXIT:-0}"
  if [[ "$exit_code" -ne "$expected_exit" ]]; then
    echo "Unexpected exit code. Expected $expected_exit, got $exit_code"
    rm -f "$stdout_file" "$stderr_file"
    return 1
  fi

  local actual_stdout actual_stderr
  actual_stdout="$(<"$stdout_file")"
  actual_stderr="$(<"$stderr_file")"
  rm -f "$stdout_file" "$stderr_file"

  if [[ "${CHECK_STDOUT:-true}" == "true" ]]; then
    local expected_stdout="${EXPECTED_STDOUT:-}"
    if [[ "$actual_stdout" != "$expected_stdout" ]]; then
      echo "Unexpected stdout."
      echo "Expected: [$expected_stdout]"
      echo "Actual:   [$actual_stdout]"
      return 1
    fi
  fi

  if [[ "${CHECK_STDERR:-false}" == "true" ]]; then
    local expected_stderr="${EXPECTED_STDERR:-}"
    if [[ "$actual_stderr" != "$expected_stderr" ]]; then
      echo "Unexpected stderr."
      echo "Expected: [$expected_stderr]"
      echo "Actual:   [$actual_stderr]"
      return 1
    fi
  fi

  if [[ -n "${POST_CHECK_CMD:-}" ]]; then
    if ! eval "$POST_CHECK_CMD"; then
      echo "Post-check command failed."
      return 1
    fi
  fi

  return 0
}
