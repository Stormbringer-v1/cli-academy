#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_window_option_equals sync:main synchronize-panes on; then
  exit 0
fi
echo "Expected synchronize-panes to be on."
exit 1
