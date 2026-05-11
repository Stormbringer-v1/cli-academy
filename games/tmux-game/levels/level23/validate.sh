#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ -f .tmux_level23.conf ]] && grep -Fq 'set -g prefix C-a' .tmux_level23.conf && tmux_global_option_equals mouse on; then
  exit 0
fi
echo "Expected mouse on and a config file containing prefix C-a."
exit 1
