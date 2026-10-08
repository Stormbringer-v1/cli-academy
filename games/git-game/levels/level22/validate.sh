#!/usr/bin/env bash
set -euo pipefail
if grep -q "cherry-pick me" file.txt 2>/dev/null; then
  exit 0
fi
echo "Cherry-picked content not found."
exit 1