#!/usr/bin/env bash
set -euo pipefail

TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${TMUX_GAME_ROOT}/tmux_common.sh"

setup_sandbox() {
  tmux_game_init
  tmuxa new-session -d -s panes -n main
}

cleanup_sandbox() {
  tmux_game_cleanup
}
