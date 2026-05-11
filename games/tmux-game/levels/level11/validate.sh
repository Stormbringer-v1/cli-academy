#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ "$(tmux_pane_count vsplit:main)" -eq 2 ]] && tmux_two_pane_orientation vsplit:main vertical; then
  exit 0
fi
echo "Expected 2 panes in a vertical arrangement."
exit 1
