#!/usr/bin/env bash
# git-game level 29: Git Submodule
set -euo pipefail

# Task: add the repository in ./submod as a submodule called 'lib', then check its status.
# Since Git 2.38 a submodule from a local path is refused unless the "file" protocol is
# allowed, so the template tells the player to allow it for this one command.
git -c protocol.file.allow=always submodule add -q ./submod lib
git submodule status
