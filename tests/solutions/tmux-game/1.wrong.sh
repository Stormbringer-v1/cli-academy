#!/usr/bin/env bash
# tmux-game level 1: Name a session (WRONG)
# Mistake: creates a new session called mysession instead of renaming temp; the validator rejects it because temp still exists.
set -euo pipefail

tmuxa new-session -d -s mysession
