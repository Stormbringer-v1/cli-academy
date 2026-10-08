#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  for i in 1 2 3 4 5 6 7 8 9 10; do
    echo "line $i" >> file.txt
    git add file.txt
    git commit -q -m "Commit $i"
  done
}
cleanup_sandbox() { :; }