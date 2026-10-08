#!/usr/bin/env bash
# git-game level boss03: BOSS 03: History Rewriting Master
set -euo pipefail

# The sandbox has ten commits on main; "Commit 7" introduces the line "BAD" into file.txt.
# A side branch, clean-fix, holds one clean commit that does not depend on it.

# 1-2. Bisect for the first commit that has "BAD" and record its hash.
first="$(git rev-list --max-parents=0 HEAD)"
git bisect start
git bisect bad HEAD
git bisect good "$first"
found=""
for _ in 1 2 3 4 5 6 7 8; do
  if grep -q '^BAD$' file.txt; then
    out="$(git bisect bad)"
  else
    out="$(git bisect good)"
  fi
  found="$(sed -n 's/^\([0-9a-f]\{40\}\) is the first bad commit$/\1/p' <<<"$out")"
  [[ -n $found ]] && break
done
echo "$found" > bad_commit.txt
git bisect reset

# 3. Cherry-pick the clean commit from the other branch onto main.
git cherry-pick clean-fix

# 4. Annotated tag.
git tag -a v1.0 -m "Bugfix release"
git log --oneline --graph --all
