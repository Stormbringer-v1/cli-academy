#!/usr/bin/env bash
# tmux-game level boss01: BOSS 01 - Sessions and Windows
set -euo pipefail

# Two sessions, each with the windows shell, editor and logs.
for session in prod staging; do
  tmuxa new-session -d -s "$session" -n shell
  tmuxa new-window -t "$session:" -n editor
  tmuxa new-window -t "$session:" -n logs
done

# Retire prod and leave staging running.
tmuxa kill-session -t prod
