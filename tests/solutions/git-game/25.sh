#!/usr/bin/env bash
# git-game level 25: Git Reflog
set -euo pipefail

# Task: recover a commit that was lost by a hard reset, using the reflog.
# The sandbox already made "Second commit" and hard-reset it away, so nothing is staged
# here: this script only reads the reflog and resets back.

# 1. View the reflog.
git reflog

# 2. Find the commit before the most recent "reset:" entry. The reflog is listed newest
#    first, so that commit is the entry right after the reset entry.
mapfile -t entries < <(git reflog --format='%H %gs')
lost=""
for i in "${!entries[@]}"; do
  if [[ "${entries[$i]#* }" == reset:* ]]; then
    lost="${entries[$((i + 1))]%% *}"
    break
  fi
done
: "${lost:?no reset entry found in the reflog}"

# 3. Recover it.
git reset -q --hard "$lost"
git log --oneline
