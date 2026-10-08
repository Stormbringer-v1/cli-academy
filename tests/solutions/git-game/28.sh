#!/usr/bin/env bash
# git-game level 28: Git Blame
set -euo pipefail

# Task: find who last modified line 2 of file.txt and write the author's name to author.txt.
git blame file.txt
author="$(git blame -L 2,2 --porcelain file.txt | sed -n 's/^author //p')"
echo "$author" > author.txt
cat author.txt
