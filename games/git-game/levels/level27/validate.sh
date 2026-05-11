#!/usr/bin/env bash
set -euo pipefail
if git tag --list | grep -q "^v1.0$"; then
  exit 0
fi
echo "Tag v1.0 not found."
exit 1