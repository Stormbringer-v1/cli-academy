#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ -f answer.txt ]] && grep -qx '2' answer.txt; then
  exit 0
fi
echo "answer.txt must contain 2."
exit 1
