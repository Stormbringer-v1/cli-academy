#!/usr/bin/env bash
# git-game level 15: Stash Changes
set -euo pipefail

# Task: stash the uncommitted changes on 'feature', then verify with the stash list.
git stash
git stash list
