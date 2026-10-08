#!/usr/bin/env bash
# git-game level 24: Git Reset Modes
set -euo pipefail

# Task: practise --soft, --mixed and --hard resets and end with only the first commit.

# 1. --soft: go back one commit, the change of "Commit 2" stays staged.
git reset --soft HEAD~1
git status --short

# 2. Unstage the file.
git reset HEAD file2.txt
git status --short

# 3. --mixed (the default). After step 1 there is no HEAD~1 any more, so bring "Commit 2"
#    back first, then reset it: the file stays in the working tree but is unstaged.
git add file2.txt
git commit -q -m "Commit 2"
git reset HEAD~1
git status --short

# 4. --hard: commit once more, then go back to the first commit and discard everything.
git add file2.txt
git commit -q -m "Commit 2"
git reset --hard HEAD~1
git log --oneline
