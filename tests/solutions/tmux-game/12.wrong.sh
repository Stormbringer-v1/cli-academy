#!/usr/bin/env bash
# tmux-game level 12: Navigate panes (WRONG)
# Mistake: selects pane 1 (off by one); the validator wants pane index 2 active.
set -euo pipefail

tmuxa select-pane -t pane-nav:main.1
