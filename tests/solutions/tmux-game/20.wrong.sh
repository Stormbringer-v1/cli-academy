#!/usr/bin/env bash
# tmux-game level 20: Copy mode (WRONG)
# Mistake: moves the cursor only 5 columns before copying, so the selection stops one character short and the buffer holds COPYM; the buffer check wants exactly COPYME.
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

wait_for_line copy:main COPYME

tmuxa copy-mode -t copy:main
tmuxa send-keys -t copy:main -X history-top
tmuxa send-keys -t copy:main -X start-of-line
tmuxa send-keys -t copy:main -X begin-selection
tmuxa send-keys -t copy:main -N 5 -X cursor-right
tmuxa send-keys -t copy:main -X copy-selection-and-cancel
