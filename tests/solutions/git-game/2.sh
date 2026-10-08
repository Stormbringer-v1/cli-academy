#!/usr/bin/env bash
# git-game level 2: Stage a file
set -euo pipefail

# Task: stage hello.txt so Git tracks it.
git add hello.txt
git status --short
