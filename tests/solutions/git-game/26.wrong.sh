#!/usr/bin/env bash
# git-game level 26: Git Bisect (WRONG)
# Mistake: writes a 6-character abbreviated hash to bad_commit.txt, shorter than the 7 characters the check requires ("Bad commit hash not written to bad_commit.txt").
set -euo pipefail

git rev-parse --short=6 HEAD > bad_commit.txt
cat bad_commit.txt
