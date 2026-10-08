#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "line1" > file.txt && git add file.txt && git commit -q -m "Initial"
  echo "line2" >> file.txt && git add file.txt && git commit -q -m "Add line 2"
  echo "line3" >> file.txt && git add file.txt && git commit -q -m "Add line 3"
}
cleanup_sandbox() { :; }