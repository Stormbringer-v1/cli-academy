#!/usr/bin/env bash
# git-game level 6: See the differences
set -euo pipefail

# Task: use 'git diff HEAD~1' to see what the last commit changed, then restore the removed line.
git diff HEAD~1 -- code.py
# The line starting with '-print' is what the previous commit had before the bug.
fixed="$(git diff HEAD~1 -- code.py | sed -n 's/^-\(print.*\)$/\1/p')"
printf '%s\n' "$fixed" > code.py
cat code.py
