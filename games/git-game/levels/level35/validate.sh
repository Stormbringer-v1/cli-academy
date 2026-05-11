#!/usr/bin/env bash
set -euo pipefail

# Check feature branch exists
if ! git branch --list | grep -q "  feature"; then
  echo "Feature branch not recovered."
  exit 1
fi

# Check tag exists
if ! git tag --list | grep -q "^v2.0$"; then
  echo "Tag v2.0 not found."
  exit 1
fi

# Check we have enough commits
commit_count=$(git rev-list --count --all)
if [[ "$commit_count" -ge 4 ]]; then
  exit 0
fi

echo "Final boss validation failed."
exit 1