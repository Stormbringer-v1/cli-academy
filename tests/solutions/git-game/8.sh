#!/usr/bin/env bash
# git-game level 8: Rename and Remove
set -euo pipefail

# Task: rename old_name.txt to new_name.txt and remove to_delete.txt, both through Git.
git mv old_name.txt new_name.txt
git rm -q to_delete.txt
git status
