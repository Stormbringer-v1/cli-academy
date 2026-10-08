#!/usr/bin/env bash
set -euo pipefail
# Observe the branch ref; works whether or not the player checked the branch out.
if git show-ref --verify --quiet refs/heads/feature; then
  exit 0
fi
echo "Branch 'feature' not found."
exit 1
