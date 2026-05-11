#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ "$(tmux_active_window_name nav)" == "logs" ]]; then
  exit 0
fi
echo "Active window should be logs."
exit 1
