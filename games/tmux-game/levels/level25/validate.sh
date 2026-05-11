#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ -x layout.sh ]] && tmux_session_exists dev && [[ "$(tmux_window_count dev)" -eq 3 ]]           && tmux_window_exists dev editor && tmux_window_exists dev server && tmux_window_exists dev logs; then
  exit 0
fi
echo "Expected executable layout.sh and dev session with editor/server/logs windows."
exit 1
