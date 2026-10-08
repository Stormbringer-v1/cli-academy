#!/usr/bin/env bash
# tmux-game level 26: Hooks
set -euo pipefail

# Every window created from now on gets renamed by the hook.
tmuxa set-hook -g after-new-window 'rename-window hooked'

# Fire the hook by creating a window.
tmuxa new-window -t hooks:

# Hooks run asynchronously in the server: wait (at most 5 s) for the rename.
for ((i = 0; i < 50; i++)); do
  if tmuxa list-windows -t hooks -F '#{window_name}' | grep -qx hooked; then
    exit 0
  fi
  sleep 0.1
done
echo "the after-new-window hook did not rename the new window" >&2
exit 1
