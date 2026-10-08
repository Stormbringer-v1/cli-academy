#!/usr/bin/env bash
# git-game level 4: Check the status (WRONG)
# Mistake: writes the name of the tracked file (README.md) instead of the untracked one, so answer.txt lacks "secret_data.txt" ("Incorrect answer.").
set -euo pipefail

git status --short
echo "README.md" > answer.txt
cat answer.txt
