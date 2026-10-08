#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "first" > file.txt && git add file.txt && git commit -q -m "First commit"
  echo "second" >> file.txt && git add file.txt && git commit -q -m "Second commit"
  git reset -q --hard HEAD~1
}
cleanup_sandbox() { :; }
