#!/usr/bin/env bash
set -euo pipefail
if git branch --list | grep -q "^  feature$"; then
  exit 0
fi
echo "Branch 'feature' not found."
exit 1