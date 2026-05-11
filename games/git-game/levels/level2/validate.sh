#!/usr/bin/env bash
set -euo pipefail
# Check that hello.txt is in the staging area
if git diff --cached --name-only | grep -q "hello.txt"; then
  exit 0
fi
# Also pass if it's already committed
if git log --oneline 2>/dev/null | head -1 | grep -q .; then
  if git ls-tree -r HEAD --name-only 2>/dev/null | grep -q "hello.txt"; then
    exit 0
  fi
fi
echo "hello.txt is not staged."
exit 1
