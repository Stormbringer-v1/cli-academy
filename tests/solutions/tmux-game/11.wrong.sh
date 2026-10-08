#!/usr/bin/env bash
# tmux-game level 11: Vertical split (WRONG)
# Mistake: uses split-window -v, which stacks the panes top/bottom instead of side by side; the orientation check rejects it.
set -euo pipefail

tmuxa split-window -v -t vsplit:main
