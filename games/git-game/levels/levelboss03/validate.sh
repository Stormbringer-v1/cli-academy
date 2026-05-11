#!/usr/bin/env bash
set -euo pipefail

# Check bad commit hash written
if [[ ! -f bad_commit.txt ]]; then
  echo "bad_commit.txt not found."
  exit 1
fi

# Check tag exists
if ! git tag --list | grep -q "v1.0"; then
  echo "Tag v1.0 not found."
  exit 1
fi

# Check commit count is reasonable (we did cherry-pick)
commit_count=$(git rev-list --count --all)
if [[ "$commit_count" -ge 10 ]]; then
  exit 0
fi

echo "Boss validation failed."
exit 1