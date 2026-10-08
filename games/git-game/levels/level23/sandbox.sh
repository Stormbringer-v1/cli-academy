#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "original" > file.txt && git add file.txt && git commit -q -m "Initial commit"
  echo "bad change" >> file.txt && git add file.txt && git commit -q -m "Bad commit"
}
cleanup_sandbox() { :; }