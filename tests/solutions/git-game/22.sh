#!/usr/bin/env bash
# git-game level 22: Cherry-pick
set -euo pipefail

# Task: apply the commit "Feature commit to cherry-pick" from 'feature' onto 'main'.
git checkout -q main
git log feature --oneline
hash="$(git log feature --grep='cherry-pick' --format='%h')"
git cherry-pick "$hash"
git log --oneline
