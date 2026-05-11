#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_capture_contains swap:main.0 RIGHT && tmux_capture_contains swap:main.1 LEFT; then
  exit 0
fi
echo "Expected pane 0 to show RIGHT and pane 1 to show LEFT."
exit 1
