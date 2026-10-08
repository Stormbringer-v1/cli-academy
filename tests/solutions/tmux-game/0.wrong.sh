#!/usr/bin/env bash
# tmux-game level 0: Start tmux (WRONG)
# Mistake: starts a session but forgets -s, so it is named "0"; the validator's has-session check for "intro" rejects it.
set -euo pipefail

tmuxa new-session -d
