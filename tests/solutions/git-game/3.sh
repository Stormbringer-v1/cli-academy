#!/usr/bin/env bash
# git-game level 3: Make your first commit
set -euo pipefail

# Task: commit the staged hello.txt.
git commit -q -m "My first commit"
git log --oneline
