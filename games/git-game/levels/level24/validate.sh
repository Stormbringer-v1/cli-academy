#!/usr/bin/env bash
set -euo pipefail
# Check only 1 commit remains after hard reset
commit_count=$(git rev-list --count --all)
if [[ "$commit_count" -eq 1 ]]; then
  if [[ -f file1.txt ]]; then
    exit 0
  fi
fi
echo "Reset may not have completed correctly."
exit 1