#!/usr/bin/env bash
# git-game level 19: Remote and Fetch
set -euo pipefail

# Task: add the remote 'origin' (the local bare repository ./upstream.git that the sandbox
# provides in place of a server) and fetch from it. Fully offline.
git remote add origin ./upstream.git
git fetch -q origin
git branch -r
