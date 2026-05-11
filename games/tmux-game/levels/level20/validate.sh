#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_buffer_equals COPYME; then
  exit 0
fi
echo "Expected tmux paste buffer to equal COPYME."
exit 1
