#!/usr/bin/env bash
# git-game level 34: Git Rerere
set -euo pipefail

# Task: enable rerere, resolve a conflict once, then redo the merge and let rerere reuse
# the recorded resolution.
git config rerere.enabled true

# First merge: conflicts, resolve by keeping both lines, commit (rerere records this).
if git merge feature -m "Merge feature"; then
  echo "merged without conflicts"
else
  sed -e '/^<<<<<<< /d' -e '/^=======$/d' -e '/^>>>>>>> /d' file.txt > file.txt.resolved
  mv file.txt.resolved file.txt
  git add file.txt
  git commit -q -m "Merge feature (conflict resolved)"
fi

# Reset and redo the merge: rerere should fill in the same resolution by itself.
git reset -q --hard HEAD~1
if git merge feature -m "Merge feature again"; then
  echo "merged without conflicts"
else
  if grep -q '^<<<<<<< ' file.txt; then
    echo "rerere did not reuse the recorded resolution"
    exit 1
  fi
  git add file.txt
  git commit -q -m "Merge feature again (resolved by rerere)"
fi
git log --oneline
