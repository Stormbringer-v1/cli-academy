#!/usr/bin/env bash
# tmux-game level 9: Multiple sessions (WRONG)
# Mistake: renames dev to ops instead of creating a second session; the validator needs both dev and ops.
set -euo pipefail

tmuxa rename-session -t dev ops
