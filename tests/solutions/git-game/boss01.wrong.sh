#!/usr/bin/env bash
# git-game level boss01: BOSS 01: First Commits Master (WRONG)
# Mistake: does every step except the amend (step 6), so the last commit message is still "Add config" ("Last commit message should be 'Initial project setup'").
set -euo pipefail

git init -q
git config user.name "Player"
git config user.email "player@cli-academy.local"

echo "# Boss project" > README.md
git add README.md
git commit -q -m "First commit"

echo 'print("hello")' > code.py
git add code.py
git commit -q -m "Add code"

echo '{"debug": false}' > config.json
git add config.json
git commit -q -m "Add config"

echo "temporary output" > temp.log
echo "temp.log" > .gitignore
git log --oneline
