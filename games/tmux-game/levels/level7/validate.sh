#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ "$(tmux_window_count closewin)" -eq 1 ]] && tmux_window_exists closewin main && ! tmux_window_exists closewin tmp; then
  exit 0
fi
echo "Expected only the main window to remain."
exit 1
