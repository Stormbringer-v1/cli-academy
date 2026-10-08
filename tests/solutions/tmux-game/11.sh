#!/usr/bin/env bash
# tmux-game level 11: Vertical split
set -euo pipefail

# A "vertical split" (side-by-side panes) is split-window -h in tmux.
tmuxa split-window -h -t vsplit:main
