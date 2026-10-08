#!/usr/bin/env bash
# git-game level 31: Git Hooks (WRONG)
# Mistake: writes .git/hooks/pre-commit but forgets `chmod +x`, so the hook is not executable ("Hook is not executable.").
set -euo pipefail

cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/bash
if git log -1 --format="%s" | grep -q "WIP"; then
  echo "WIP commits are not allowed!"
  exit 1
fi
HOOK
ls -l .git/hooks/pre-commit
