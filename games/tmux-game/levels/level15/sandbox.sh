#!/usr/bin/env bash

      TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${TMUX_GAME_ROOT}/tmux_common.sh"

      setup_sandbox() {
        tmux_game_init
        tmuxa new-session -d -s layout -n main
tmuxa split-window -h -t layout:main
tmuxa split-window -v -t layout:main.0
tmuxa split-window -v -t layout:main.1
      }

      cleanup_sandbox() {
        tmux_game_cleanup
      }
