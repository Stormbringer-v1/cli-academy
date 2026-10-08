#!/usr/bin/env bash
# tmux-game level 22: Command mode (WRONG)
# Mistake: forgets -g, so status-left is only set on the session; the validator checks the global option.
set -euo pipefail

tmuxa set-option -t cmdmode status-left CMDMODE
