#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_window_exists hooks hooked && tmux_hook_output_contains after-new-window; then
  exit 0
fi
echo "Expected after-new-window hook and a window named hooked."
exit 1
