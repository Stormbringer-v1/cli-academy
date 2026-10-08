#!/usr/bin/env bash
# git-game level 13: 3-way Merge
set -euo pipefail

# Task: merge 'feature' into 'main'. Both branches changed the same spot, so the
# merge stops with a conflict: resolve it (keep both changes) and commit.
if git merge feature -m "Merge feature into main"; then
  echo "merged without conflicts"
else
  echo "conflict: keeping both sides"
  sed -e '/^<<<<<<< /d' -e '/^=======$/d' -e '/^>>>>>>> /d' file.txt > file.txt.resolved
  mv file.txt.resolved file.txt
  git add file.txt
  git commit -q -m "Merge feature into main"
fi
git log --oneline
