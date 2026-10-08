#!/usr/bin/env bash
set -euo pipefail
# Check if old_name.txt and to_delete.txt are no longer in the repository index
if git ls-files | grep -q "^old_name.txt$" || git ls-files | grep -q "^to_delete.txt$"; then
  echo "Some files are still being tracked by Git."
  exit 1
fi

# Check if new_name.txt is correctly staged as a move
if ! git diff --cached --name-only | grep -q "new_name.txt"; then
  echo "The renamed file 'new_name.txt' is not staged."
  exit 1
fi

# Check if the move was detected properly (optional but better)
if ! git status | grep -q "renamed:    old_name.txt -> new_name.txt"; then
  echo "The move was not correctly detected by Git."
  exit 1
fi

exit 0
