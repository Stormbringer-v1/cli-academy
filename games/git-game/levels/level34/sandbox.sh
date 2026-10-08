#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "line1" > file.txt && git add file.txt && git commit -q -m "Initial"
  git checkout -q -b feature
  echo "line1" > file.txt
  echo "feature line" >> file.txt
  git add file.txt && git commit -q -m "Feature change"
  git checkout -q main
  echo "line1" > file.txt
  echo "main line" >> file.txt
  git add file.txt && git commit -q -m "Main change"
}
cleanup_sandbox() { :; }