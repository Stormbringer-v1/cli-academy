#!/usr/bin/env bash
# git-game level 21: Git Rebase --onto
set -euo pipefail

# Task: move the commits of the old-feature chain onto main with 'git rebase --onto'.
# The template command names a branch called 'feature', but the sandbox only has
# 'old-feature', so create 'feature' from it first (tests/known-issues/git-game.md).
git branch feature old-feature
if git rebase --onto main old-feature~1 feature; then
  echo "rebased without conflicts"
else
  # The moved commit conflicts with main's change: keep both sides and continue.
  sed -e '/^<<<<<<< /d' -e '/^=======$/d' -e '/^>>>>>>> /d' file.txt > file.txt.resolved
  mv file.txt.resolved file.txt
  git add file.txt
  git -c core.editor=true rebase --continue
fi
git log --oneline --graph --all
