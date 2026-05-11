#!/usr/bin/env bash
set -euo pipefail

# tmux-game: Learn tmux through isolated socket challenges

if ! command -v tmux >/dev/null 2>&1; then
  echo "Error: tmux is not installed."
  echo "Install tmux and try again."
  echo "  macOS: brew install tmux"
  echo "  Ubuntu/Debian: sudo apt install tmux"
  echo "  Fedora: sudo dnf install tmux"
  exit 1
fi

tmux_version="$(tmux -V | awk '{print $2}')"
tmux_major="${tmux_version%%.*}"
if (( tmux_major < 3 )); then
  echo "Error: tmux-game requires tmux >= 3.0"
  echo "Detected version: ${tmux_version}"
  exit 1
fi

LEVEL_ORDER=(
  0 1 2 3 4 5 6 7 8 9
  boss01
  10 11 12 13 14 15 16 17 18 19
  boss02
  20 21 22 23 24 25 26 27
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_PATH="$SCRIPT_DIR/../../engine/engine.sh"

if [[ ! -f "$ENGINE_PATH" ]]; then
  echo "Error: Game engine not found at $ENGINE_PATH"
  exit 1
fi

source "$ENGINE_PATH"
start_game "$@"
