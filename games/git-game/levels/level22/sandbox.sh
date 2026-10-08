#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "main file" > file.txt && git add file.txt && git commit -q -m "Initial commit"
  git checkout -q -b feature
  echo "cherry-pick me" >> file.txt && git add file.txt && git commit -q -m "Feature commit to cherry-pick"
  git checkout -q main
}
cleanup_sandbox() { :; }