#!/usr/bin/env bash
# tmux-game level 21: Paste buffer
set -euo pipefail

# Wait (at most 5 s) until the pane text contains $2.
wait_for_text() {
  local target=$1 text=$2 out i
  for ((i = 0; i < 50; i++)); do
    out="$(tmuxa capture-pane -p -t "$target")"
    if grep -Fq "$text" <<<"$out"; then
      return 0
    fi
    sleep 0.1
  done
  echo "timed out waiting for '$text' in $target" >&2
  return 1
}

# Paste the most recent buffer (BUFFER-TEXT) into the only pane.
tmuxa paste-buffer -t paste:main.0

wait_for_text paste:main.0 BUFFER-TEXT
