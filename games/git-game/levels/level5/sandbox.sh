#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  
  echo "v1" > file.txt && git add file.txt && git commit -m "First commit" -q
  echo "v2" > file.txt && git add file.txt && git commit -m "FIND_ME_NOW" -q
  echo "v3" > file.txt && git add file.txt && git commit -m "Third commit" -q
}
cleanup_sandbox() { :; }
