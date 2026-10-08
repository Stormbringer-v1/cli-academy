#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  
  echo "Important code" > main.py
  echo "Debug log data" > debug.log
  git add main.py debug.log
  git commit -m "First commit with accidental debug log" -q
}
cleanup_sandbox() { :; }
