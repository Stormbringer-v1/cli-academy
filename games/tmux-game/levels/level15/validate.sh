#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ "$(tmux_pane_count layout:main)" -eq 4 ]] && tmux_all_panes_equal_height layout:main; then
  exit 0
fi
echo "Expected four panes with roughly equal heights."
exit 1
