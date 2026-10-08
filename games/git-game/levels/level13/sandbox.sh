#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "Line 1" > file.txt
  echo "Line 2" >> file.txt
  git add file.txt && git commit -q -m "Initial commit"
  git checkout -q -b feature
  echo "Line 1" > file.txt
  echo "Feature change" >> file.txt
  echo "Line 2" >> file.txt
  git add file.txt && git commit -q -m "Feature change"
  git checkout -q main
  echo "Line 1" > file.txt
  echo "Main change" >> file.txt
  echo "Line 2" >> file.txt
  git add file.txt && git commit -q -m "Main change"
}
cleanup_sandbox() { :; }