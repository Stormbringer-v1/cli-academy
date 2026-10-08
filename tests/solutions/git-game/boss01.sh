#!/usr/bin/env bash
# git-game level boss01: BOSS 01: First Commits Master
set -euo pipefail

# 1-2. Initialize the repository and configure the identity for this repository only.
git init -q
git config user.name "Player"
git config user.email "player@cli-academy.local"

# 3. README.md, committed with "First commit".
echo "# Boss project" > README.md
git add README.md
git commit -q -m "First commit"

# 4. code.py, committed with "Add code".
echo 'print("hello")' > code.py
git add code.py
git commit -q -m "Add code"

# 5. config.json, committed with "Add config".
echo '{"debug": false}' > config.json
git add config.json
git commit -q -m "Add config"

# 6. Amend the last commit message.
git commit -q --amend -m "Initial project setup"

# 7. temp.log exists but is ignored and untracked.
echo "temporary output" > temp.log
echo "temp.log" > .gitignore
git status --short
git log --oneline
