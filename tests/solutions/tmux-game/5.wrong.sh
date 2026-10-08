#!/usr/bin/env bash
# tmux-game level 5: Switch windows (WRONG)
# Mistake: presses "next window" twice (main -> logs -> main), ending on main; the validator wants logs active.
set -euo pipefail

tmuxa next-window -t nav
tmuxa next-window -t nav
