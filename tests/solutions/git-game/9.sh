#!/usr/bin/env bash
# git-game level 9: Fix the typo
set -euo pipefail

# Task: amend the last commit message ("Initial commti") to "Initial commit".
git commit -q --amend -m "Initial commit"
git log -1 --format=%s
