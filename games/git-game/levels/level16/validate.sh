#!/usr/bin/env bash
set -euo pipefail
# Observe that the stash was popped; never pop it.
if [[ -n "$(git stash list)" ]]; then
  echo "The stash is not empty. Run: git stash pop"
  exit 1
fi
if ! grep -q "changes" file.txt 2>/dev/null; then
  echo "The stashed changes are not back in file.txt."
  exit 1
fi
exit 0
