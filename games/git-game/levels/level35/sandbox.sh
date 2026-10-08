#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "initial" > file.txt && git add file.txt && git commit -q -m "Initial commit"
  git checkout -q -b feature
  echo "feature" > feature.txt && git add feature.txt && git commit -q -m "Feature commit"
  git checkout -q main
  echo "main" >> file.txt && git add file.txt && git commit -q -m "Main commit"
  git branch -D feature
}
cleanup_sandbox() { :; }