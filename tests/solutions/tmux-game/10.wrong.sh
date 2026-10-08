#!/usr/bin/env bash
# tmux-game level 10: Horizontal split (WRONG)
# Mistake: uses split-window -h, which puts the panes side by side instead of stacked top/bottom; the orientation check rejects it.
set -euo pipefail

tmuxa split-window -h -t panes:main
