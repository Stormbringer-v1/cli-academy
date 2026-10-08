#!/usr/bin/env bash
set -euo pipefail
# cwd is SANDBOX_DIR; the repository is ./repo and the worktree must be ./feature-work.
if ! git -C repo worktree list --porcelain | grep -q '^worktree .*/feature-work$'; then
  echo "No worktree at feature-work. From repo/ run: git worktree add ../feature-work feature"
  exit 1
fi
if ! git -C repo show feature:file.txt 2>/dev/null | grep -q "worktree"; then
  echo "The feature branch has no commit adding 'worktree' to file.txt."
  exit 1
fi
exit 0
