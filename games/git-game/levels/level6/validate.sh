#!/usr/bin/env bash
set -euo pipefail
# Correct content
CORRECT_CONTENT='print("Hello, SnapSecurity Academy!")'

if [[ -f "code.py" ]]; then
  USER_CONTENT=$(cat code.py | tr -d '[:space:]')
  COMPARE_CONTENT=$(echo "$CORRECT_CONTENT" | tr -d '[:space:]')
  if [[ "$USER_CONTENT" == "$COMPARE_CONTENT" ]]; then
    exit 0
  fi
fi
echo "The file 'code.py' does not have the correct code yet."
exit 1
