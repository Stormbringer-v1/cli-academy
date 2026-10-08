#!/usr/bin/env bash
# tmux-game level 18: Swap panes
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

# Look at the panes first, as a player would: LEFT in pane 0, RIGHT in pane 1.
wait_for_line swap:main.0 LEFT
wait_for_line swap:main.1 RIGHT

tmuxa swap-pane -s swap:main.0 -t swap:main.1

# Pane 0 must now show RIGHT and pane 1 LEFT.
wait_for_line swap:main.0 RIGHT
wait_for_line swap:main.1 LEFT
