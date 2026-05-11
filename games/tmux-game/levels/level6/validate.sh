#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_window_exists rename editor && ! tmux_window_exists rename shell; then
  exit 0
fi
echo "Window should be named editor."
exit 1
