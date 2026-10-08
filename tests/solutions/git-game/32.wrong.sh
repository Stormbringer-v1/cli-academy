#!/usr/bin/env bash
# git-game level 32: Filter Branch (WRONG)
# Mistake: the tree-filter names the wrong file ("secrets.txt"), so history is rewritten but secret.txt stays in the commit that added it ("secret.txt still in history.").
set -euo pipefail

export FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch --tree-filter 'rm -f secrets.txt' -- --all
git for-each-ref --format='%(refname)' refs/original | while read -r ref; do
  git update-ref -d "$ref"
done
git log --all --name-status
