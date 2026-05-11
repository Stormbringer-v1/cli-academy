#!/usr/bin/env bash
set -euo pipefail
if git stash pop 2>/dev/null; then
  if grep -q "changes" file.txt 2>/dev/null; then
    if ! git stash list | grep -q "stash"; then
      exit 0
    fi
  fi
fi
echo "Stash pop failed."
exit 1