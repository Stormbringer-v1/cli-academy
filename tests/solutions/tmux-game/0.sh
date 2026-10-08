#!/usr/bin/env bash
# tmux-game level 0: Start tmux
set -euo pipefail

# Start the "intro" session. -d creates it already detached, which is what
# "new-session, then Ctrl-b d" ends up as when there is no terminal.
tmuxa new-session -d -s intro
