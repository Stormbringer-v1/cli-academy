#!/usr/bin/env bash
set -euo pipefail
if git stash 2>/dev/null; then
  if git stash list | grep -q "stash"; then
    exit 0
  fi
fi
echo "Stash failed."
exit 1