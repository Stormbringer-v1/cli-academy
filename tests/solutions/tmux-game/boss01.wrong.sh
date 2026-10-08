#!/usr/bin/env bash
# tmux-game level boss01: BOSS 01 - Sessions and Windows (WRONG)
# Mistake: builds both sessions correctly but never kills prod; the validator requires prod to be gone.
set -euo pipefail

for session in prod staging; do
  tmuxa new-session -d -s "$session" -n shell
  tmuxa new-window -t "$session:" -n editor
  tmuxa new-window -t "$session:" -n logs
done
