#!/usr/bin/env bash
set -euo pipefail
GIT_DIR="${GIT_DIR:-.}"
cd "$GIT_DIR" 2>/dev/null || cd .

if ! grep -q "Hello Universe" greeting.txt 2>/dev/null; then
  echo "greeting.txt does not contain 'Hello Universe'"
  exit 1
fi

if git -C "$GIT_DIR" rev-parse --verify MERGE_HEAD >/dev/null 2>&1; then
  echo "Merge is still in progress."
  exit 1
fi

if [[ $(git -C "$GIT_DIR" log --oneline | wc -l) -lt 3 ]]; then
  echo "No merge commit found."
  exit 1
fi
exit 0