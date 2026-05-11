#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  for i in 1 2 3 4 5; do echo "$i" >> file.txt && git add file.txt && git commit -q -m "Commit $i"; done
}
cleanup_sandbox() { :; }