#!/usr/bin/env bash
# CLI Academy test harness library.
#
# Sourced by tests/run-level.sh, tests/run-game.sh and tests/harness-selftest.sh.
# Contains only function definitions and assignments, so sourcing it never
# changes the caller's shell options (the callers run with `set -uo pipefail`).

# harness_repo_root: print the absolute repo root (two directories above this file).
harness_repo_root() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  printf '%s\n' "$here"
}

# harness_level_order <play.sh>: print the LEVEL_ORDER tokens, one per line.
# The lint (tests/lint-levels.sh) uses the same pipeline.
harness_level_order() {
  awk '/^[[:space:]]*LEVEL_ORDER=\(/{f=1} f{print} f && /\)/{exit}' "$1" |
    sed -e 's/#.*$//' -e 's/^[[:space:]]*LEVEL_ORDER=(//' -e 's/).*$//' |
    tr -s ' \t' '\n\n' | tr -d "\"'" | sed '/^$/d'
}

# harness_conf_get <level.conf> <VAR>: print VAR's value after evaluating ONLY
# the plain assignments in the file; no other command in the file ever runs.
# A DEBUG trap with `extdebug` skips every command whose trap handler returns
# non-zero, so `echo`, `touch` and even commands inside $(...) never run.
# Pass an absolute path for $1.
HARNESS_CONF_INNER=$(cat <<'INNER'
__f=$1; __v=$2
__t() {
  [[ ${BASH_SOURCE[1]:-} == "$__f" ]] || return 0
  [[ $2 =~ ^[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?\+?= ]] && return 0
  return 1
}
shopt -s extdebug
trap '__t "$LINENO" "$BASH_COMMAND"' DEBUG
source "$__f"
trap - DEBUG
printf '%s' "${!__v-}"
INNER
)
harness_conf_get() {
  [[ -f $1 ]] || return 1
  env -i PATH="$PATH" bash --norc --noprofile -c "$HARNESS_CONF_INNER" harness-conf "$1" "$2" 2>/dev/null
}

# harness_verdict_name <code>: map a run-level.sh exit code to its verdict name.
harness_verdict_name() {
  case "${1:-}" in
    0) printf 'PASS' ;;
    1) printf 'FAIL' ;;
    2) printf 'ERROR' ;;
    3) printf 'TIMEOUT' ;;
    4) printf 'CRASH' ;;
    5) printf 'LEAK' ;;
    *) printf 'UNKNOWN' ;;
  esac
}
