#!/usr/bin/env bash
# git-game level 30: Git Worktree
set -euo pipefail

# Task: create a worktree for 'feature' next to the repository, then add "worktree" to
# file.txt inside it and commit.
# The sandbox keeps the repository in ./repo; depending on the engine the shell may
# already be inside it.
if [[ -d repo ]]; then
  cd repo
fi
git worktree add ../feature-work feature
cd ../feature-work
echo "worktree" >> file.txt
git add file.txt
git commit -q -m "Add worktree line"
git worktree list
