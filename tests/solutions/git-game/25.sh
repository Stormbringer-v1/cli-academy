#!/usr/bin/env bash
# git-game level 25: Git Reflog
set -euo pipefail

# Task: recover a commit that was lost by a hard reset, using the reflog.
# The sandbox only holds "First commit" (nothing is lost yet), so first stage the
# accident the template describes: make a second commit and hard-reset it away.
echo "second" >> file.txt
git add file.txt
git commit -q -m "Second commit"
git reset -q --hard HEAD~1

# 1-3. Find the lost commit in the reflog and reset back to it.
git reflog
lost="$(git reflog --format='%H %gs' | grep 'commit: Second commit' | head -n 1 | cut -d' ' -f1)"
git reset -q --hard "$lost"
git log --oneline
