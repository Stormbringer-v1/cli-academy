#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_session_exists dev && tmux_session_exists ops; then
  exit 0
fi
echo "Both dev and ops sessions must exist."
exit 1
