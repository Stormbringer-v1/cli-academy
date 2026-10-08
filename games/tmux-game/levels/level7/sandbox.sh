#!/usr/bin/env bash

      TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${TMUX_GAME_ROOT}/tmux_common.sh"

      setup_sandbox() {
        tmux_game_init
        tmuxa new-session -d -s closewin -n main
tmuxa new-window -t closewin -n tmp
      }

      cleanup_sandbox() {
        tmux_game_cleanup
      }
