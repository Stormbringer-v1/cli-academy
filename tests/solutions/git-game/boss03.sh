#!/usr/bin/env bash
# git-game level boss03: BOSS 03: History Rewriting Master
set -euo pipefail

# The template says "Commit 7 has BAD", but the sandbox commits only append "line N"
# to file.txt (no commit contains the text BAD, and there is no other branch).
# So the stand-in for "BAD" is the line that first appears in Commit 7: "line 7".
main_branch="$(git branch --show-current)"

# 1-2. Bisect for the first commit that has the marker and record its hash.
first="$(git rev-list --max-parents=0 HEAD)"
git bisect start
git bisect bad HEAD
git bisect good "$first"
found=""
for _ in 1 2 3 4 5 6 7 8; do
  if grep -q '^line 7$' file.txt; then
    out="$(git bisect bad)"
  else
    out="$(git bisect good)"
  fi
  found="$(sed -n 's/^\([0-9a-f]\{40\}\) is the first bad commit$/\1/p' <<<"$out")"
  [[ -n $found ]] && break
done
echo "$found" > bad_commit.txt
git bisect reset

# 3. Cherry-pick a clean commit from another branch: branch off just before the bad
# commit, make a clean commit there, then cherry-pick it onto the main line.
git branch clean "${found}~1"
git checkout -q clean
echo "clean fix" > fix.txt
git add fix.txt
git commit -q -m "Clean fix"
git checkout -q "$main_branch"
git cherry-pick clean

# 4. Annotated tag.
git tag -a v1.0 -m "Bugfix release"
git log --oneline --graph --all
