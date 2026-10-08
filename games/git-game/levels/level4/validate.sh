#!/usr/bin/env bash
set -euo pipefail
if [[ -f "answer.txt" ]] && grep -qi "secret_data.txt" answer.txt; then
  exit 0
fi
echo "Incorrect answer. Run 'git status' and look at the untracked files."
exit 1
