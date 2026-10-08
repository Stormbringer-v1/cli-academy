#!/usr/bin/env bash
# tmux-game level boss02: BOSS 02 - Monitoring Dashboard (WRONG)
# Mistake: builds four labelled panes but forgets to rename the window to "monitor"; the validator finds no 4-pane dashboard:monitor.
set -euo pipefail

tmuxa split-window -h -t dashboard:main
tmuxa split-window -v -t dashboard:main.0
tmuxa split-window -v -t dashboard:main.2
tmuxa select-layout -t dashboard:main tiled

pane=0
for label in cpu mem disk logs; do
  tmuxa send-keys -t "dashboard:main.$pane" "echo $label" C-m
  pane=$((pane + 1))
done
