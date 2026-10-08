#!/usr/bin/env bash
# git-game level 27: Git Tag
set -euo pipefail

# Task: tag the current commit as the annotated release v1.0.
git tag -a v1.0 -m "First release version"
git tag --list
