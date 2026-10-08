#!/usr/bin/env bash
# git-game level 30: Git Worktree
set -euo pipefail

# Task: from the repository in ./repo create a worktree for 'feature' at ../feature-work,
# then add "worktree" to file.txt inside it and commit.
cd repo
git worktree add -q ../feature-work feature
cd ../feature-work
echo "worktree" >> file.txt
git add file.txt
git commit -q -m "Add worktree line"
git worktree list
