#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "main file" > file.txt
  git add file.txt && git commit -q -m "Initial commit"
  git checkout -q -b feature
  echo "feature content" >> file.txt
  git add file.txt && git commit -q -m "Add feature"
  git checkout -q main
}
cleanup_sandbox() { :; }