#!/usr/bin/env bash
# git-game level 23: Git Revert (WRONG)
# Mistake: removes the bad commit with `git reset --hard HEAD~1` (rewriting history) instead of `git revert`, so no revert commit exists (needs at least 3 commits: "Revert may not have completed.").
set -euo pipefail

git reset -q --hard HEAD~1
git log --oneline
