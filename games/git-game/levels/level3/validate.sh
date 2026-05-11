#!/usr/bin/env bash
set -euo pipefail
# Check if there is at least one commit
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git rev-list -n 1 --all >/dev/null 2>&1; then
  exit 0
fi
echo "No commits found in the repository."
exit 1
