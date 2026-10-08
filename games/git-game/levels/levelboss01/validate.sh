#!/usr/bin/env bash
set -euo pipefail
# 1. Check if .git directory exists
if [[ ! -d ".git" ]]; then
  echo "Error: Git repository not initialized."
  exit 1
fi

# 2. Check if identity was configured
NAME=$(git config user.name 2>/dev/null || echo "")
EMAIL=$(git config user.email 2>/dev/null || echo "")
if [[ -z "$NAME" || -z "$EMAIL" ]]; then
  echo "Error: Identity (user.name or user.email) not configured locally."
  exit 1
fi

# 3. Check if we have 3 commits (minimum)
COMMIT_COUNT=$(git rev-list --count --all 2>/dev/null || echo "0")
if [[ "$COMMIT_COUNT" -lt 3 ]]; then
  echo "Error: Expected at least 3 commits. Found $COMMIT_COUNT."
  exit 1
fi

# 4. Check if files README.md, code.py, config.json exist and are tracked
for file in README.md code.py config.json; do
  if [[ ! -f "$file" ]]; then
    echo "Error: File $file not found."
    exit 1
  fi
  if ! git ls-files | grep -q "^$file$"; then
    echo "Error: File $file is not being tracked by Git."
    exit 1
  fi
done

# 5. Check last commit message (amended)
LAST_MSG=$(git log -1 --format="%s" 2>/dev/null || echo "")
if [[ "$LAST_MSG" != "Initial project setup" ]]; then
  echo "Error: Last commit message should be 'Initial project setup'. Found: '$LAST_MSG'"
  exit 1
fi

# 6. Check .gitignore and temp.log
if ! grep -q "^temp.log" .gitignore 2>/dev/null; then
  echo "Error: temp.log is not listed in .gitignore."
  exit 1
fi

if git ls-files | grep -q "^temp.log$"; then
  echo "Error: temp.log is still being tracked by Git."
  exit 1
fi

exit 0
