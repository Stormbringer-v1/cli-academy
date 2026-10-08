#!/usr/bin/env bash
# tmux-game level 21: Paste buffer (WRONG)
# Mistake: shows the buffer (show-buffer) instead of pasting it into the pane; the pane never receives BUFFER-TEXT, so the content check rejects it.
set -euo pipefail

tmuxa show-buffer
# the buffer text comes without a trailing newline; end the line so the output stays readable
echo
