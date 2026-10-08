#!/usr/bin/env bash
set -euo pipefail
current=$(git branch --show-current)
if [[ "$current" == "develop" ]]; then
  exit 0
fi
echo "Currently on '$current', not 'develop'."
exit 1