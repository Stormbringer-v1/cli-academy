#!/usr/bin/env bash
set -euo pipefail
if git merge feature --no-edit 2>/dev/null; then
  exit 0
fi
echo "Merge failed."
exit 1