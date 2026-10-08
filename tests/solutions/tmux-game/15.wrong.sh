#!/usr/bin/env bash
# tmux-game level 15: Preset layouts (WRONG)
# Mistake: applies main-vertical instead of even-horizontal; the stacked side panes keep unequal heights and the height check rejects it.
set -euo pipefail

tmuxa select-layout -t layout:main main-vertical
