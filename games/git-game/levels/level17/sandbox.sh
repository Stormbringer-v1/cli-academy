#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "1" > file.txt && git add file.txt && git commit -q -m "Commit 1"
  git checkout -q -b feature
  echo "2" >> file.txt && git add file.txt && git commit -q -m "Commit 2"
  git checkout -q main
  echo "3" >> file.txt && git add file.txt && git commit -q -m "Commit 3"
}
cleanup_sandbox() { :; }