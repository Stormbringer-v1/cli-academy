#!/usr/bin/env bash
# git-game level 26: Git Bisect
set -euo pipefail

# Task: use git bisect to find the commit that introduced "BAD" and write its hash to bad_commit.txt.
git bisect start
git bisect bad
git bisect good HEAD~4

# At every step test the checked out commit for "BAD" and mark it (bounded loop).
found=""
for _ in 1 2 3 4 5 6; do
  if grep -q "BAD" file.txt; then
    out="$(git bisect bad)"
  else
    out="$(git bisect good)"
  fi
  echo "$out"
  found="$(sed -n 's/^\([0-9a-f]\{40\}\) is the first bad commit$/\1/p' <<<"$out")"
  [[ -n $found ]] && break
done

echo "$found" > bad_commit.txt
git bisect reset
cat bad_commit.txt
