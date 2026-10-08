#!/usr/bin/env bash

      TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${TMUX_GAME_ROOT}/tmux_common.sh"

      setup_sandbox() {
        tmux_game_init
        tmuxa new-session -d -s zoom -n main
tmuxa split-window -h -t zoom:main
tmuxa split-window -v -t zoom:main.1
tmuxa select-pane -t zoom:main.0
      }

      cleanup_sandbox() {
        tmux_game_cleanup
      }
