#!/usr/bin/env bash
# git-game level 11: Switching Branches (WRONG)
# Mistake: uses `git checkout -b dev`, which creates and switches to a new branch instead of the existing "develop" ("Currently on 'dev', not 'develop'.").
set -euo pipefail

git checkout -q -b dev
git branch --show-current
