#!/usr/bin/env bash
set -euo pipefail
# Observe the remote and the fetched ref; never add or fetch (no network).
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "No remote named origin. Run: git remote add origin ./upstream.git"
  exit 1
fi
if ! git rev-parse --verify -q refs/remotes/origin/main >/dev/null; then
  echo "origin/main not found. Run: git fetch origin"
  exit 1
fi
exit 0
