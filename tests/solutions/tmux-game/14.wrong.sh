#!/usr/bin/env bash
# tmux-game level 14: Zoom a pane (WRONG)
# Mistake: toggles zoom twice (like pressing Ctrl-b z twice), ending unzoomed; the validator wants the window zoomed.
set -euo pipefail

tmuxa resize-pane -Z -t zoom:main.0
tmuxa resize-pane -Z -t zoom:main.0
