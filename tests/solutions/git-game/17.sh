#!/usr/bin/env bash
# git-game level 17: Git Graph
set -euo pipefail

# Task: look at the branching history and write the number of commits that are only on
# the 'feature' branch to branch_commits.txt.
git log --graph --oneline --all
count="$(git rev-list --count main..feature)"
echo "$count" > branch_commits.txt
cat branch_commits.txt
