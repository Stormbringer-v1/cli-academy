#!/usr/bin/env bash
set -euo pipefail
# Add a remote and fetch from it
git remote add origin https://github.com/example/repo.git 2>/dev/null || true
if git fetch origin 2>/dev/null; then
  exit 0
fi
echo "Remote fetch failed."
exit 1