#!/usr/bin/env bash
# git-game level 26: Git Bisect
set -euo pipefail

# Task: use git bisect to find the commit that introduced "BAD" and write its hash to bad_commit.txt.
git bisect start
git bisect bad
git bisect good HEAD~4

# Let git run the test at every step: exit 0 marks the checked out commit good (no BAD line),
# exit 1 marks it bad. Git stops by itself once the culprit is isolated.
git bisect run sh -c '! grep -q "BAD" file.txt'

# Read the result from the ref git maintains, not from its (version-dependent) messages.
found="$(git rev-parse refs/bisect/bad)"

echo "$found" > bad_commit.txt
git bisect reset
cat bad_commit.txt
