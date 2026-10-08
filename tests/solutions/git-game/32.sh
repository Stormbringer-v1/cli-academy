#!/usr/bin/env bash
# git-game level 32: Filter Branch
set -euo pipefail

# Task: remove secret.txt from every commit of the history.
export FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch --tree-filter 'rm -f secret.txt' -- --all

# filter-branch keeps the old history reachable under refs/original (so 'git log --all'
# still lists secret.txt). Drop those backup refs and the reflog to really remove it.
git for-each-ref --format='%(refname)' refs/original | while read -r ref; do
  git update-ref -d "$ref"
done
git reflog expire --expire=now --all
git gc -q --prune=now

# Verify, like the template suggests (but match the file name: the commit message
# "Add secret" would always match a plain 'grep secret').
if git log --all --name-status | grep -q 'secret\.txt'; then
  echo "secret.txt is still in the history"
else
  echo "secret.txt is gone from the history"
fi
