#!/usr/bin/env bash
set -euo pipefail
# Check that we have 3 commits (initial, bad, revert) and file has original only
commit_count=$(git rev-list --count --all)
if [[ "$commit_count" -ge 3 ]]; then
  if ! grep -q "bad change" file.txt 2>/dev/null; then
    exit 0
  fi
fi
echo "Revert may not have completed."
exit 1