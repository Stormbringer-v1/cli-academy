#!/usr/bin/env bash
# git-game level 29: Git Submodule
set -euo pipefail

# Task: add /tmp/submod as a submodule called 'lib', then check its status.
git submodule add /tmp/submod lib
git submodule status
