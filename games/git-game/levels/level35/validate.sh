#!/usr/bin/env bash
set -euo pipefail
# Observe the repaired repository; never repair it.
if ! git rev-parse --verify -q refs/heads/feature >/dev/null; then
  echo "Feature branch not recovered."
  exit 1
fi
if ! git log --format=%s feature | grep -qx "Feature commit"; then
  echo "feature does not point at the original 'Feature commit'."
  exit 1
fi
if ! git merge-base --is-ancestor feature main; then
  echo "main has not been rebased onto feature."
  exit 1
fi
if [[ -n "$(git rev-list --merges main)" ]]; then
  echo "main still contains merge commits; history is not linear."
  exit 1
fi
if [[ "$(git cat-file -t v2.0 2>/dev/null || true)" != "tag" ]]; then
  echo "Annotated tag v2.0 not found."
  exit 1
fi
if ! git tag -l --format='%(contents)' v2.0 | grep -q "Production release"; then
  echo "Tag v2.0 does not carry the message \"Production release\"."
  exit 1
fi
exit 0
