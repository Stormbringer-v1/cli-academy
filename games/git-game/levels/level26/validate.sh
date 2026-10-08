#!/usr/bin/env bash
set -euo pipefail
# For bisect, we check if bad_commit.txt exists with a valid hash
if [[ -f bad_commit.txt ]]; then
  hash=$(cat bad_commit.txt)
  if [[ -n "$hash" && ${#hash} -ge 7 ]]; then
    exit 0
  fi
fi
echo "Bad commit hash not written to bad_commit.txt"
exit 1