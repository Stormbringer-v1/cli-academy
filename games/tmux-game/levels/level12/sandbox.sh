#!/usr/bin/env bash
      set -euo pipefail

      TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${TMUX_GAME_ROOT}/tmux_common.sh"

      setup_sandbox() {
        tmux_game_init
        tmuxa new-session -d -s pane-nav -n main
tmuxa split-window -h -t pane-nav:main
tmuxa split-window -v -t pane-nav:main.1
tmuxa select-pane -t pane-nav:main.0
      }

      cleanup_sandbox() {
        tmux_game_cleanup
      }
