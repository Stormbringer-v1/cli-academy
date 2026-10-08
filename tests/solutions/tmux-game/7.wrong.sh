#!/usr/bin/env bash
# tmux-game level 7: Close a window (WRONG)
# Mistake: closes main instead of tmp; the validator wants main to remain and tmp to be gone.
set -euo pipefail

tmuxa kill-window -t closewin:main
