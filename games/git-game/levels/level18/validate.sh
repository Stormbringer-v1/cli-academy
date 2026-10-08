#!/usr/bin/env bash
set -euo pipefail
# Observe that feature was deleted; never delete it.
if git rev-parse --verify -q refs/heads/feature >/dev/null; then
  echo "Branch feature still exists. Run: git branch -d feature"
  exit 1
fi
if ! git rev-parse --verify -q refs/heads/main >/dev/null; then
  echo "Branch main is missing."
  exit 1
fi
exit 0
