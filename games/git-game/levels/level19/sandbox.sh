#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "content" > file.txt && git add file.txt && git commit -q -m "Initial commit"
}
cleanup_sandbox() { :; }