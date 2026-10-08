#!/usr/bin/env bash
# git-game level 27: Git Tag (WRONG)
# Mistake: names the tag "1.0" without the leading "v", so the tag list has no exact "v1.0" ("Tag v1.0 not found.").
set -euo pipefail

git tag -a 1.0 -m "First release version"
git tag --list
