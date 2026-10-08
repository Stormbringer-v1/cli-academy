#!/usr/bin/env bash
# tmux-game level 16: Move panes between windows (WRONG)
# Mistake: uses break-pane, which moves the pane into a brand-new third window instead of into window two; window two keeps only 1 pane.
set -euo pipefail

tmuxa break-pane -d -s movepane:one.2
