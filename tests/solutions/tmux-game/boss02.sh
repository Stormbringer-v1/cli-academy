#!/usr/bin/env bash
# tmux-game level boss02: BOSS 02 - Monitoring Dashboard
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

tmuxa rename-window -t dashboard:main monitor

# Three splits give four panes; tile them into a 2x2 grid.
tmuxa split-window -h -t dashboard:monitor
tmuxa split-window -v -t dashboard:monitor.0
tmuxa split-window -v -t dashboard:monitor.2
tmuxa select-layout -t dashboard:monitor tiled

# One label per pane.
pane=0
for label in cpu mem disk logs; do
  tmuxa send-keys -t "dashboard:monitor.$pane" "echo $label" C-m
  pane=$((pane + 1))
done

# Wait until every label has been printed.
pane=0
for label in cpu mem disk logs; do
  wait_for_line "dashboard:monitor.$pane" "$label"
  pane=$((pane + 1))
done
