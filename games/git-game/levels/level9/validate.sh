#!/usr/bin/env bash
set -euo pipefail
# Correct message
CORRECT_MSG="Initial commit"

if git log -1 --format="%s" | grep -q "^$CORRECT_MSG$"; then
  exit 0
fi
echo "The last commit message still contains the typo."
exit 1
