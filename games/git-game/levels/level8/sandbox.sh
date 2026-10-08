#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  
  echo "Original file" > old_name.txt
  echo "To be deleted" > to_delete.txt
  git add old_name.txt to_delete.txt
  git commit -m "First commit with files to be moved or removed" -q
}
cleanup_sandbox() { :; }
