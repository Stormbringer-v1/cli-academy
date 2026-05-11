#!/usr/bin/env bash
set -euo pipefail
current=$(git branch --show-current)
if [[ "$current" == "feature" ]]; then
  commit_count=$(git rev-list --count HEAD)
  if [[ "$commit_count" -ge 2 ]]; then
    exit 0
  fi
fi
echo "Rebase --onto may not have completed."
exit 1