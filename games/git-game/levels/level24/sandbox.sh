#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  # Four commits, so that all four steps of the template can run in order:
  # --soft HEAD~1, unstage file2.txt (the last commit's file), --mixed HEAD~1, --hard HEAD~1.
  echo "file1" > file1.txt && git add file1.txt && git commit -q -m "Commit 1"
  echo "extra1" > extra1.txt && git add extra1.txt && git commit -q -m "Commit 2"
  echo "extra2" > extra2.txt && git add extra2.txt && git commit -q -m "Commit 3"
  echo "file2" > file2.txt && git add file2.txt && git commit -q -m "Commit 4"
}
cleanup_sandbox() { :; }
