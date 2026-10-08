#!/usr/bin/env bash
set -uo pipefail

# git-game: Learn Git through interactive terminal challenges
# Part of CLI Academy — https://github.com/Stormbringer-v1/cli-academy

# Check dependency
if ! command -v git &>/dev/null; then
  echo "❌ Error: git is not installed."
  echo "   Install git and try again."
  echo "   • macOS: brew install git"
  echo "   • Ubuntu/Debian: sudo apt install git"
  echo "   • Fedora: sudo dnf install git"
  exit 2
fi

# 1. Define level order (38 levels total)
# shellcheck disable=SC2034  # LEVEL_ORDER is read by engine/engine.sh
LEVEL_ORDER=(
  0 1 2 3 4 5 6 7 8 9
  boss01
  10 11 12 13 14 15 16 17 18 19
  boss02
  20 21 22 23 24 25 26 27 28 29
  boss03
  30 31 32 33 34 35
)

# 2. Source the game engine
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_PATH="$SCRIPT_DIR/../../engine/engine.sh"

if [[ ! -f "$ENGINE_PATH" ]]; then
  echo "❌ Error: Game engine not found at $ENGINE_PATH"
  exit 2
fi

# shellcheck source=../../engine/engine.sh
source "$ENGINE_PATH"

# 3. Start the game
start_game "$@"
