#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_global_option_equals status-right academy; then
  exit 0
fi
echo "Expected status-right to equal academy."
exit 1
