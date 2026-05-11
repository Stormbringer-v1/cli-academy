#!/usr/bin/env bash
set -euo pipefail

# bash-game: Learn shell scripting through interactive challenges

if ! command -v bash >/dev/null 2>&1; then
  echo "Error: bash is not installed."
  exit 1
fi

if (( BASH_VERSINFO[0] < 4 )); then
  echo "Error: bash-game requires bash >= 4.0"
  echo "macOS users: brew install bash"
  exit 1
fi

LEVEL_ORDER=(
  0 1 2 3 4 5 6 7 8 9
  boss01
  10 11 12 13 14 15 16 17 18 19
  boss02
  20 21 22 23 24 25 26 27 28 29
  boss03
  30 31 32 33 34 35 36 37
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_PATH="$SCRIPT_DIR/../../engine/engine.sh"

if [[ ! -f "$ENGINE_PATH" ]]; then
  echo "Error: Game engine not found at $ENGINE_PATH"
  exit 1
fi

source "$ENGINE_PATH"
start_game "$@"
