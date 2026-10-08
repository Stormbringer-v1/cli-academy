#!/usr/bin/env bash
set -euo pipefail
# Observe the stash; never create it.
if [[ -z "$(git stash list)" ]]; then
  echo "No stash entry found. Run: git stash"
  exit 1
fi
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "The working tree still has uncommitted changes."
  exit 1
fi
exit 0
