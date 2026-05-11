#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if ! tmux_session_exists prod && tmux_session_exists staging && [[ "$(tmux_window_count staging)" -eq 3 ]]           && tmux_window_exists staging shell && tmux_window_exists staging editor && tmux_window_exists staging logs; then
  exit 0
fi
echo "Expected only staging with shell/editor/logs windows."
exit 1
