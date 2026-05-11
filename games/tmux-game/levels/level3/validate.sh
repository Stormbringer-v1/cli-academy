#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_session_exists attachme && [[ "$(tmux_client_count attachme)" -eq 0 ]]; then
  exit 0
fi
echo "Session attachme should exist with zero attached clients."
exit 1
