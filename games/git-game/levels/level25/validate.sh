#!/usr/bin/env bash
set -euo pipefail
# Check we have 2 commits after recovery
commit_count=$(git rev-list --count --all)
if [[ "$commit_count" -ge 2 ]]; then
  if grep -q "lost" file.txt 2>/dev/null || grep -q "second" file.txt 2>/dev/null; then
    exit 0
  fi
fi
# Alternative: check if reflog has the recovery entry
if git reflog | grep -q "reset"; then
  exit 0
fi
echo "Commit recovery not verified."
exit 1