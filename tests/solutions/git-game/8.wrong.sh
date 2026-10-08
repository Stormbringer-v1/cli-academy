#!/usr/bin/env bash
# git-game level 8: Rename and Remove (WRONG)
# Mistake: uses plain mv and rm instead of git mv / git rm, so the old names are still tracked in the index ("Some files are still being tracked by Git.").
set -euo pipefail

mv old_name.txt new_name.txt
rm to_delete.txt
git status --short
