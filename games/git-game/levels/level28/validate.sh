#!/usr/bin/env bash
set -euo pipefail
if [[ -f author.txt ]]; then
  if grep -q "Player" author.txt 2>/dev/null; then
    exit 0
  fi
fi
echo "author.txt not found or wrong author."
exit 1