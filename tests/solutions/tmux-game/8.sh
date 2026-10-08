#!/usr/bin/env bash
# tmux-game level 8: Kill a session
set -euo pipefail

tmuxa kill-session -t deleteme
