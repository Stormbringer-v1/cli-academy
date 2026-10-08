#!/usr/bin/env bash
# tmux-game level 4: Create a window (WRONG)
# Mistake: typo in the window name ("note"); the validator wants a window named exactly "notes".
set -euo pipefail

tmuxa new-window -t windows -n note
