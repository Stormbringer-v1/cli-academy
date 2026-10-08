#!/usr/bin/env bash
# git-game level 1: Set your identity (WRONG)
# Mistake: sets only user.name and forgets user.email, so validate.sh rejects with "user.email is not set."
set -euo pipefail

git config user.name "Test Player"
git config --local --list
