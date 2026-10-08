#!/usr/bin/env bash
# git-game level 24: Git Reset Modes (WRONG)
# Mistake: undoes the last commit with `git revert` instead of `git reset`, which adds a commit, so three commits remain instead of one ("Reset may not have completed correctly.").
set -euo pipefail

git revert --no-edit HEAD
git log --oneline
