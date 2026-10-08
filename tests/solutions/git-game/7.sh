#!/usr/bin/env bash
# git-game level 7: Ignore the noise
set -euo pipefail

# Task: stop tracking debug.log without deleting it, and ignore it.
git rm -q --cached debug.log
echo "debug.log" >> .gitignore
git status --short
