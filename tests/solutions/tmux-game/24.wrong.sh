#!/usr/bin/env bash
# tmux-game level 24: Status bar customization (WRONG)
# Mistake: sets status-left instead of status-right; the validator checks status-right.
set -euo pipefail

tmuxa set-option -g status-left academy
