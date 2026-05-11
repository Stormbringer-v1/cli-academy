#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "v1" > file.txt && git add file.txt && git commit -q -m "Version 1"
}
cleanup_sandbox() { :; }