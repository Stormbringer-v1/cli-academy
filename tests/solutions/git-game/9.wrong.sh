#!/usr/bin/env bash
# git-game level 9: Fix the typo (WRONG)
# Mistake: amends the commit but with the wrong capitalisation ("Initial Commit"), so the subject check fails ("The last commit message still contains the typo.").
set -euo pipefail

git commit -q --amend -m "Initial Commit"
git log -1 --format=%s
