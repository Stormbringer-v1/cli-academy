#!/usr/bin/env bash
# git-game level 11: Switching Branches
set -euo pipefail

# Task: switch to the existing 'develop' branch.
git checkout -q develop
git branch --show-current
