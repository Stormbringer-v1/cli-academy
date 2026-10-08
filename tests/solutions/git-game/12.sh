#!/usr/bin/env bash
# git-game level 12: Fast-forward Merge
set -euo pipefail

# Task: merge 'feature' into 'main' (a fast-forward, since main has no new commits).
git merge feature -m "Merge feature"
git log --oneline
