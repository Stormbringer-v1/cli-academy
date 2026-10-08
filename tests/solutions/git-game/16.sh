#!/usr/bin/env bash
# git-game level 16: Stash Pop vs Apply
set -euo pipefail

# Task: bring the stashed changes back and drop the stash entry.
git stash pop
git status --short
