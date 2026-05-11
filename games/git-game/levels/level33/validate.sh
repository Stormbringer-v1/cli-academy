#!/usr/bin/env bash
set -euo pipefail
commit_count=$(git rev-list --count --all)
parents=$(git log --format=%P -1)
parent_count=$(echo "$parents" | wc -w)
if [[ "$parent_count" -ge 3 ]]; then
  exit 0
fi
echo "Octopus merge did not complete."
exit 1