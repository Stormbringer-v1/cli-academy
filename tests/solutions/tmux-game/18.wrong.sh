#!/usr/bin/env bash
# tmux-game level 18: Swap panes (WRONG)
# Mistake: only moves the focus to pane 1 instead of swapping the panes, so pane 0 still shows LEFT; the content check rejects it.
set -euo pipefail

tmuxa select-pane -t swap:main.1
