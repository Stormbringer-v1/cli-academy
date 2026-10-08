#!/usr/bin/env bash

      TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${TMUX_GAME_ROOT}/tmux_common.sh"

      setup_sandbox() {
        tmux_game_init
        tmuxa new-session -d -s swap -n main
tmuxa split-window -h -t swap:main
tmuxa send-keys -t swap:main.0 'printf "LEFT\n"' C-m
tmuxa send-keys -t swap:main.1 'printf "RIGHT\n"' C-m
      }

      cleanup_sandbox() {
        tmux_game_cleanup
      }
