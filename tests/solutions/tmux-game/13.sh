#!/usr/bin/env bash
# tmux-game level 13: Resize panes
set -euo pipefail

# Move the border between the two panes 10 columns to the right.
tmuxa resize-pane -t resize:main.0 -R 10
