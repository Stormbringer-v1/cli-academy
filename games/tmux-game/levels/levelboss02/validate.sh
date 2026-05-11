#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ "$(tmux_pane_count dashboard:monitor)" -ne 4 ]]; then
  echo "Expected 4 panes in dashboard:monitor."
  exit 1
fi

for label in cpu mem disk logs; do
  found=0
  for pane in 0 1 2 3; do
    if tmux_capture_contains "dashboard:monitor.${pane}" "$label"; then
      found=1
      break
    fi
  done
  if [[ "$found" -ne 1 ]]; then
    echo "Missing pane label: $label"
    exit 1
  fi
done

exit 0
