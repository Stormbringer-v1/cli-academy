#!/usr/bin/env bash
# git-game level 23: Git Revert
set -euo pipefail

# Task: undo the bad commit without rewriting history.
git log --oneline
git revert --no-edit HEAD
git log --oneline
