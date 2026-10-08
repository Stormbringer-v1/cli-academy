#!/usr/bin/env bash
set -euo pipefail
# Pass only if the repository has at least one commit (HEAD resolves).
if git rev-parse --verify -q HEAD >/dev/null; then
  exit 0
fi
echo "No commits found in the repository."
exit 1
