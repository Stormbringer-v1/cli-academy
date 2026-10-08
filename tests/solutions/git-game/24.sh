#!/usr/bin/env bash
# git-game level 24: Git Reset Modes
set -euo pipefail

# Task: practise --soft, --mixed and --hard resets and end with only the first commit.
# The sandbox holds four commits, so every step of the template runs as written.

# 1. --soft: go back one commit, the change of the last commit (file2.txt) stays staged.
git reset --soft HEAD~1
git status --short

# 2. Unstage the file.
git reset HEAD file2.txt
git status --short

# 3. --mixed (the default): go back one more commit and unstage everything.
git reset HEAD~1
git status --short

# 4. --hard: go back to the first commit and discard the tracked changes.
git reset --hard HEAD~1
git log --oneline
