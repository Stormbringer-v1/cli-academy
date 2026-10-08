#!/usr/bin/env bash
# git-game level 0: Initialize your journey (WRONG)
# Mistake: runs git init inside a new subdirectory, so there is no .git in the current directory (the `[[ -d .git ]]` check fails).
set -euo pipefail

mkdir project
cd project
git init -q
echo "git init ran in project/ -> .git here and in the parent: $(ls -d .git ../.git 2>&1 | tr '\n' ' ')"
