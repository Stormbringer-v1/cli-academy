#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_capture_contains send:main.1 synced; then
  exit 0
fi
echo "Expected pane 1 to contain 'synced'."
exit 1
