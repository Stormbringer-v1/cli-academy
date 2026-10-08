#!/usr/bin/env bash
# tmux-game level 23: tmux.conf basics
set -euo pipefail

# The config file the task asks for.
cat > .tmux_level23.conf <<'CONF_EOF'
set -g mouse on
set -g prefix C-a
CONF_EOF

# Load it into the running server.
tmuxa source-file .tmux_level23.conf
