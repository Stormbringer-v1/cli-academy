#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "initial" > file.txt && git add file.txt && git commit -q -m "Initial commit"
  git checkout -q -b feature
  echo "feature" >> file.txt && git add file.txt && git commit -q -m "Feature commit"
  git checkout -q main
  echo "main" >> file.txt && git add file.txt && git commit -q -m "Main commit"
  git branch -d feature
}
cleanup_sandbox() { :; }