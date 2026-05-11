#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_session_exists mysession && ! tmux_session_exists temp; then
  exit 0
fi
echo "Expected only session 'mysession'."
exit 1
