#!/usr/bin/env bash
# tmux-game level 19: Send keys
set -euo pipefail

# Wait (at most 5 s) until a pane shows a line that is exactly $2.
wait_for_line() {
  local target=$1 text=$2 out i
  for ((i = 0; i < 50; i++)); do
    out="$(tmuxa capture-pane -p -t "$target")"
    if grep -qx "$text" <<<"$out"; then
      return 0
    fi
    sleep 0.1
  done
  echo "timed out waiting for '$text' in $target" >&2
  return 1
}

tmuxa send-keys -t send:main.1 'echo synced' C-m

# The command was executed if its output (the bare word) is on screen.
wait_for_line send:main.1 synced
