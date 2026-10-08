#!/usr/bin/env bash
# git-game level 14: Resolve Merge Conflict
set -euo pipefail

# Task: resolve the merge conflict in greeting.txt, keep "Hello Universe", commit the resolution.
# The sandbox does not start the merge for the player, so merge 'feature' first.
if git merge feature -m "Merge feature"; then
  echo "merged without conflicts"
else
  git status --short
  echo "Hello Universe" > greeting.txt
  git add greeting.txt
  git commit -q -m "Resolved merge conflict"
fi
git log --oneline
