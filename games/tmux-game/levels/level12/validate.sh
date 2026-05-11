#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ "$(tmux_current_pane_index pane-nav:main)" == "2" ]]; then
  exit 0
fi
echo "Active pane should be index 2."
exit 1
