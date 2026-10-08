#!/usr/bin/env bash
# git-game level 33: Octopus Merge
set -euo pipefail

# Task: merge feature1, feature2 and feature3 into main with a single octopus merge.
git merge feature1 feature2 feature3 -m "Octopus merge"
git log --oneline --graph
