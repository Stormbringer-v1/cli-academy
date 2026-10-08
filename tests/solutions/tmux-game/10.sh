#!/usr/bin/env bash
# tmux-game level 10: Horizontal split
set -euo pipefail

# A "horizontal split" (panes stacked top/bottom) is split-window -v in tmux.
tmuxa split-window -v -t panes:main
