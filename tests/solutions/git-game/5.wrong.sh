#!/usr/bin/env bash
# git-game level 5: Search the history (WRONG)
# Mistake: copies the abbreviated hash from `git log --oneline` instead of the full SHA-1, so hash.txt is not the full hash ("Incorrect hash.").
set -euo pipefail

short="$(git log --oneline --grep='FIND_ME_NOW' | cut -d' ' -f1)"
echo "$short" > hash.txt
cat hash.txt
