#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "first" > file.txt && git add file.txt && git commit -q -m "First commit"
}
cleanup_sandbox() { :; }