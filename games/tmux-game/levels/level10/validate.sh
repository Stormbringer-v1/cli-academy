#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ "$(tmux_pane_count panes:main)" -eq 2 ]] && tmux_two_pane_orientation panes:main horizontal; then
  exit 0
fi
echo "Expected 2 panes in a horizontal arrangement."
exit 1
