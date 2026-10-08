#!/usr/bin/env bash
set -euo pipefail
if git log --all --name-status | grep -q "secret.txt"; then
  echo "secret.txt still in history."
  exit 1
fi
exit 0