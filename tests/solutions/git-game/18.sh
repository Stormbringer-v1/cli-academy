#!/usr/bin/env bash
# git-game level 18: Delete Merged Branches
set -euo pipefail

# Task: delete the already merged 'feature' branch.
git branch -d feature
git branch --list
