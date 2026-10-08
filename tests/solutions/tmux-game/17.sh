#!/usr/bin/env bash
# tmux-game level 17: Synchronize panes
set -euo pipefail

tmuxa set-window-option -t sync:main synchronize-panes on
