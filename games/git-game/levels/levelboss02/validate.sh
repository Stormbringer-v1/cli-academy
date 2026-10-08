#!/usr/bin/env bash
set -euo pipefail

# Check we're on main
current=$(git branch --show-current)
if [[ "$current" != "main" ]]; then
  echo "Error: Not on main branch. Currently on '$current'."
  exit 1
fi

# Check feature branch was deleted
if git branch --list | grep -q "  feature"; then
  echo "Error: Feature branch still exists."
  exit 1
fi

# Check we have at least 3 commits (initial, feature, main, merge)
commit_count=$(git rev-list --count --all)
if [[ "$commit_count" -lt 4 ]]; then
  echo "Error: Expected at least 4 commits. Found $commit_count."
  exit 1
fi

# Check file.txt has both lines
if ! grep -q "main" file.txt 2>/dev/null; then
  echo "Error: main work not found in file.txt"
  exit 1
fi
if ! grep -q "feature" file.txt 2>/dev/null; then
  echo "Error: feature work not found in file.txt"
  exit 1
fi

# Check merge commit exists (has 2 parents)
merge_count=$(git log --merges --oneline | wc -l)
if [[ "$merge_count" -lt 1 ]]; then
  echo "Error: No merge commit found."
  exit 1
fi

exit 0