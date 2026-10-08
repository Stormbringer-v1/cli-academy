#!/usr/bin/env bash
# git-game level boss02: BOSS 02: Branching Boss Fight
set -euo pipefail

# 1-2. Create the 'feature' branch and switch to it.
git branch feature
git checkout -q feature

# 3. Add "feature work" on a new line and commit.
echo "feature work" >> file.txt
git add file.txt
git commit -q -m "Add feature work"

# 4. Switch back to main.
git checkout -q main

# 5. Add "main work" on a new line and commit.
echo "main work" >> file.txt
git add file.txt
git commit -q -m "Add main work"

# 6-8. Merge feature into main; both branches changed the same spot, so resolve the
# conflict by keeping BOTH lines and commit the merge.
if git merge feature -m "Merge feature with conflict resolved"; then
  echo "merged without conflicts"
else
  sed -e '/^<<<<<<< /d' -e '/^=======$/d' -e '/^>>>>>>> /d' file.txt > file.txt.resolved
  mv file.txt.resolved file.txt
  git add file.txt
  git commit -q -m "Merge feature with conflict resolved"
fi

# 9. Stash any remaining changes (there are none).
git stash

# 10. Delete the merged feature branch.
git branch -d feature
git log --oneline --graph
