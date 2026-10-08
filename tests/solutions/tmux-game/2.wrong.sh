#!/usr/bin/env bash
# tmux-game level 2: List sessions (WRONG)
# Mistake: redirects the session listing itself into answer.txt instead of the count; the validator wants the line "2".
set -euo pipefail

tmuxa ls > answer.txt
