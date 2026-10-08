#!/usr/bin/env bash
# tmux-game level 23: tmux.conf basics (WRONG)
# Mistake: writes the config file but never loads it with source-file, so mouse is still off; the validator checks the live global option.
set -euo pipefail

cat > .tmux_level23.conf <<'CONF_EOF'
set -g mouse on
set -g prefix C-a
CONF_EOF
