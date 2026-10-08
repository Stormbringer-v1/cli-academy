#!/usr/bin/env bash
set -euo pipefail
# Check we're on feature and it has 3 commits (rebased)
if [[ "$(git branch --show-current)" != "feature" ]]; then
  echo "Not on feature branch."
  exit 1
fi
commit_count=$(git rev-list --count HEAD)
if [[ "$commit_count" -ge 3 ]]; then
  exit 0
fi
echo "Rebase may not have completed."
exit 1