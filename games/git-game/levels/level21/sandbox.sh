#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "base" > file.txt && git add file.txt && git commit -q -m "Base commit"
  git checkout -q -b old-feature
  echo "old1" >> file.txt && git add file.txt && git commit -q -m "Old feature 1"
  echo "old2" >> file.txt && git add file.txt && git commit -q -m "Old feature 2"
  git checkout -q main
  echo "main" >> file.txt && git add file.txt && git commit -q -m "Main update"
}
cleanup_sandbox() { :; }