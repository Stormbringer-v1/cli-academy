#!/usr/bin/env bash
setup_sandbox() {
  mkdir repo
  cd repo
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "main" > file.txt && git add file.txt && git commit -q -m "Initial commit"
  git checkout -q -b feature
  echo "feature" >> file.txt && git add file.txt && git commit -q -m "Feature commit"
  git checkout -q main
}
cleanup_sandbox() { :; }
