#!/usr/bin/env bash
# tmux-game level 14: Zoom a pane
set -euo pipefail

# -Z toggles zoom; the window starts unzoomed, so this zooms pane 0.
tmuxa resize-pane -Z -t zoom:main.0
