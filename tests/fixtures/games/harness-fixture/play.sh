#!/usr/bin/env bash
# Self-test fixture for tests/run-level.sh and tests/run-game.sh. Not a real game.
set -uo pipefail
# shellcheck disable=SC2034  # used by the sourced engine
LEVEL_ORDER=(pass xfail slow leak setupfail exitcode nosolution)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_PATH="$SCRIPT_DIR/../../engine/engine.sh"            # legacy-mode copy layout
if [[ ! -f "$ENGINE_PATH" ]]; then
  ENGINE_PATH="$SCRIPT_DIR/../../../../engine/engine.sh"    # in-repo layout
fi
if [[ ! -f "$ENGINE_PATH" ]]; then
  echo "Error: engine not found" >&2
  exit 2
fi
# shellcheck source=/dev/null
source "$ENGINE_PATH"
start_game "$@"
