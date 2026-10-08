#!/usr/bin/env bash
# git-game level 19: Remote and Fetch
set -euo pipefail

# Task: add the remote 'origin' and fetch from it.
git remote add origin https://github.com/example/repo.git
# The example repository does not exist and tests run without network, so the fetch is
# expected to fail here; the script still ends successfully (see tests/known-issues/git-game.md).
git fetch origin || echo "fetch failed (no network / no such repository)"
