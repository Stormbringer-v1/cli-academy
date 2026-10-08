#!/usr/bin/env bash
set -euo pipefail
# Get the correct hash
CORRECT_HASH=$(git log --all --grep="FIND_ME_NOW" --format="%H" | head -n 1)

if [[ -f "hash.txt" ]]; then
  USER_HASH=$(cat hash.txt | tr -d '[:space:]')
  if [[ "$USER_HASH" == "$CORRECT_HASH"* ]]; then
    exit 0
  fi
fi
echo "Incorrect hash. Use 'git log' and copy the full hash for the commit with 'FIND_ME_NOW'."
exit 1
