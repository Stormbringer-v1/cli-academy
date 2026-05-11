#!/usr/bin/env bash
set -euo pipefail
if git branch -d feature 2>/dev/null; then
  if ! git branch --list | grep -q "feature"; then
    exit 0
  fi
fi
echo "Branch deletion failed."
exit 1