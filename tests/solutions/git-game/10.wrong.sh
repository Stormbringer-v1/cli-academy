#!/usr/bin/env bash
# git-game level 10: Create a branch (WRONG)
# Mistake: creates the branch under a different name ("features"), so no branch called exactly "feature" exists ("Branch 'feature' not found.").
set -euo pipefail

git branch features
git branch --list
