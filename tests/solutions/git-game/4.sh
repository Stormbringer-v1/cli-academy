#!/usr/bin/env bash
# git-game level 4: Check the status
set -euo pipefail

# Task: find the untracked file with 'git status' and write its name to answer.txt.
# Read the status into a variable first, so answer.txt itself is not listed as untracked.
untracked="$(git status --porcelain | sed -n 's/^?? //p')"
echo "$untracked" > answer.txt
cat answer.txt
