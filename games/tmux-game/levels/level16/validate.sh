#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ "$(tmux_pane_count movepane:one)" -eq 2 ]] && [[ "$(tmux_pane_count movepane:two)" -eq 2 ]]; then
  exit 0
fi
echo "Both windows should end with 2 panes."
exit 1
