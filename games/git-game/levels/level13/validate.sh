#!/usr/bin/env bash
set -euo pipefail
# Observe the result of the player's 3-way merge; never perform it.
if [[ "$(git symbolic-ref --short -q HEAD || true)" != "main" ]]; then
  echo "You are not on main. Run: git checkout main"
  exit 1
fi
if [[ -n "$(git diff --name-only --diff-filter=U)" ]]; then
  echo "There are unresolved conflicts. Fix file.txt, git add it and commit."
  exit 1
fi
if ! git merge-base --is-ancestor feature HEAD; then
  echo "feature is not merged into main yet. Run: git merge feature"
  exit 1
fi
if [[ "$(git rev-list --parents -n 1 HEAD | wc -w)" -lt 3 ]]; then
  echo "HEAD is not a merge commit; a 3-way merge was expected."
  exit 1
fi
exit 0
