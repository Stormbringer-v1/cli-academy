#!/usr/bin/env bash
      set -euo pipefail

      TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${TMUX_GAME_ROOT}/tmux_common.sh"

      setup_sandbox() {
        tmux_game_init
        tmuxa new-session -d -s movepane -n one
tmuxa split-window -h -t movepane:one
tmuxa split-window -v -t movepane:one.1
tmuxa new-window -t movepane -n two
      }

      cleanup_sandbox() {
        tmux_game_cleanup
      }
