#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if tmux_capture_contains paste:main.0 BUFFER-TEXT; then
  exit 0
fi
echo "Expected BUFFER-TEXT in the target pane."
exit 1
