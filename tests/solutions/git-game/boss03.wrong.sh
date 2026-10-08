#!/usr/bin/env bash
# git-game level boss03: BOSS 03: History Rewriting Master (WRONG)
# Mistake: writes bad_commit.txt but forgets the final annotated tag v1.0 (step 4), so the validator reports "Tag v1.0 not found."
set -euo pipefail

bad="$(git log --grep='^Commit 7$' --format='%H')"
echo "$bad" > bad_commit.txt
git log --oneline -n 3
