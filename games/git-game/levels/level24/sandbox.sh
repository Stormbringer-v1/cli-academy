#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "file1" > file1.txt && git add file1.txt && git commit -q -m "Commit 1"
  echo "file2" > file2.txt && git add file2.txt && git commit -q -m "Commit 2"
}
cleanup_sandbox() { :; }