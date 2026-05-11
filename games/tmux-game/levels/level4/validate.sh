#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ "$(tmux_window_count windows)" -eq 2 ]] && tmux_window_exists windows notes; then
  exit 0
fi
echo "Expected 2 windows including 'notes'."
exit 1
