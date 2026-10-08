#!/usr/bin/env bash
# tmux-game level 6: Rename a window (WRONG)
# Mistake: renames the session instead of the window; the validator finds no window named "editor" in session "rename".
set -euo pipefail

tmuxa rename-session -t rename editor
