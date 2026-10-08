#!/usr/bin/env bash
# tmux-game level 13: Resize panes (WRONG)
# Mistake: resizes in the wrong direction (-L instead of -R), so the left pane does not get wider; the width check rejects it.
set -euo pipefail

tmuxa resize-pane -t resize:main.0 -L 10
