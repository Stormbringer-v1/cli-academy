#!/usr/bin/env bash
# tmux-game level 3: Attach and detach
set -euo pipefail

# Attaching needs a terminal, so give the client a pseudo-terminal with
# script(1). The chained command detaches again right after attaching.
script -qec "tmux -L $TMUX_SOCKET attach -t attachme \; detach-client" /dev/null </dev/null >/dev/null
