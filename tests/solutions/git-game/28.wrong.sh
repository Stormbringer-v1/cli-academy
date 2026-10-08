#!/usr/bin/env bash
# git-game level 28: Git Blame (WRONG)
# Mistake: writes the commit message of line 2 ("Add line 2") instead of the author's name, so author.txt lacks "Player" ("author.txt not found or wrong author.").
set -euo pipefail

git log --grep='line 2' --format=%s > author.txt
cat author.txt
