#!/usr/bin/env bash
# tmux-game level 22: Command mode
set -euo pipefail

# Same command you would type after Ctrl-b : in the tmux command prompt.
tmuxa set-option -g status-left CMDMODE
