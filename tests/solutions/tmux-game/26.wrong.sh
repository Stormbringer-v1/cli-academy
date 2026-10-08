#!/usr/bin/env bash
# tmux-game level 26: Hooks (WRONG)
# Mistake: creates the new window before installing the hook, so the hook never fires and no window is named "hooked"; the window-name check rejects it.
set -euo pipefail

tmuxa new-window -t hooks:
tmuxa set-hook -g after-new-window 'rename-window hooked'
