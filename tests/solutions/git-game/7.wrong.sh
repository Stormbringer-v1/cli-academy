#!/usr/bin/env bash
# git-game level 7: Ignore the noise (WRONG)
# Mistake: only adds debug.log to .gitignore and forgets `git rm --cached`, so the file is still tracked ("debug.log is still being tracked by Git.").
set -euo pipefail

echo "debug.log" >> .gitignore
git status --short
