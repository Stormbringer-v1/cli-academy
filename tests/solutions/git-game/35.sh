#!/usr/bin/env bash
# git-game level 35: FINAL BOSS: Real-World Scenario
set -euo pipefail

# 1. Recover the accidentally deleted 'feature' branch from the reflog.
git reflog
lost="$(git reflog --format='%H %gs' | grep 'commit: Feature commit' | head -n 1 | cut -d' ' -f1)"
git checkout -q -b feature "$lost"

# 2. Rebase main onto feature to make the history linear (both changed file.txt: keep both).
git checkout -q main
if git rebase feature; then
  echo "rebased without conflicts"
else
  sed -e '/^<<<<<<< /d' -e '/^=======$/d' -e '/^>>>>>>> /d' file.txt > file.txt.resolved
  mv file.txt.resolved file.txt
  git add file.txt
  git -c core.editor=true rebase --continue
fi

# 3. Annotated tag.
git tag -a v2.0 -m "Production release"

# 4. Use git bisect to verify that the initial commit is "good".
initial="$(git rev-list --max-parents=0 HEAD)"
git bisect start HEAD "$initial"
git bisect reset
git log --oneline --graph --all
