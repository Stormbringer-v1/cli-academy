#!/usr/bin/env bash
# tmux-game level 2: List sessions
set -euo pipefail

# One line per session in `ls`: count them and write only the number.
tmuxa ls | wc -l | tr -d ' ' > answer.txt
