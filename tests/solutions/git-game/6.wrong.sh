#!/usr/bin/env bash
# git-game level 6: See the differences (WRONG)
# Mistake: rewrites code.py with an approximate message instead of restoring the exact original, so the content check fails ("does not have the correct code yet").
set -euo pipefail

git diff HEAD~1 -- code.py
echo 'print("Hello, Academy!")' > code.py
cat code.py
