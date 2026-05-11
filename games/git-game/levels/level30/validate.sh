#!/usr/bin/env bash
set -euo pipefail
WORKTREE_DIR="../feature-work"
if [[ ! -d "$WORKTREE_DIR" ]]; then
  echo "Worktree directory not found. Run: git worktree add ../feature-work feature"
  exit 1
fi
if ! grep -q "worktree" "$WORKTREE_DIR/file.txt" 2>/dev/null; then
  echo "file.txt in the worktree does not contain 'worktree'. Add it and commit."
  exit 1
fi
exit 0
