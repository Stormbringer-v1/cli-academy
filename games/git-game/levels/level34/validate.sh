#!/usr/bin/env bash
set -euo pipefail
if git config rerere.enabled | grep -q "true"; then
  exit 0
fi
# Check rerere directory exists
if [[ -d ".git/rrcache" ]]; then
  exit 0
fi
echo "Rerere not enabled."
exit 1