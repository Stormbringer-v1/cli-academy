#!/usr/bin/env bash
# tmux-game level 16: Move panes between windows
set -euo pipefail

# Window "one" has 3 panes (0-2), window "two" has 1: move pane 2 over.
tmuxa join-pane -s movepane:one.2 -t movepane:two
