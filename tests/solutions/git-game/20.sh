#!/usr/bin/env bash
# git-game level 20: Git Rebase
set -euo pipefail

# Task: switch to 'feature' and rebase it onto 'main'.
git checkout -q feature
git rebase main
git log --oneline --graph
