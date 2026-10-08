#!/usr/bin/env bash
# tmux-game level 19: Send keys (WRONG)
# Mistake: sends the command to pane 0 instead of pane 1; the validator finds no "synced" in pane 1.
set -euo pipefail

tmuxa send-keys -t send:main.0 'echo synced' C-m
