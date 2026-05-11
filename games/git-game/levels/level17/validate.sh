#!/usr/bin/env bash
set -euo pipefail
# Check git log --graph shows both branches
if git log --graph --oneline | grep -q "|"; then
  exit 0
fi
echo "Git graph does not show branching."
exit 1