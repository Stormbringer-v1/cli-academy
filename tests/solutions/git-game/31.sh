#!/usr/bin/env bash
# git-game level 31: Git Hooks
set -euo pipefail

# Task: create an executable .git/hooks/pre-commit that is meant to refuse "WIP" commits,
# try a WIP commit, then commit properly.
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/bash
if git log -1 --format="%s" | grep -q "WIP"; then
  echo "WIP commits are not allowed!"
  exit 1
fi
HOOK
chmod +x .git/hooks/pre-commit

echo "work in progress" >> file.txt
git add file.txt
# As written in the template the hook only looks at the previous commit, so it does not
# actually refuse this WIP commit (see tests/known-issues/git-game.md).
git commit -m "WIP: first draft" || echo "WIP commit was refused by the hook"
git commit -m "Add first draft" || echo "second commit was refused by the hook"
git log --oneline
