#!/usr/bin/env bash
# git-game level 5: Search the history
set -euo pipefail

# Task: find the commit whose message is FIND_ME_NOW and write its full SHA-1 to hash.txt.
hash="$(git log --grep='FIND_ME_NOW' --format='%H')"
echo "$hash" > hash.txt
cat hash.txt
