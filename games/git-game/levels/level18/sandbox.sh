#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "main" > file.txt && git add file.txt && git commit -q -m "Initial commit"
  git checkout -q -b feature
  echo "feature work" >> file.txt && git add file.txt && git commit -q -m "Feature commit"
  git checkout -q main
  git merge feature -q --no-edit
}
cleanup_sandbox() { :; }