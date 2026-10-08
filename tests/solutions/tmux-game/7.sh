#!/usr/bin/env bash
# tmux-game level 7: Close a window
set -euo pipefail

tmuxa kill-window -t closewin:tmp
