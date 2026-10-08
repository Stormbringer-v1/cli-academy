#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  # Create some tracked files
  echo "Tracked" > README.md
  git add README.md
  git commit -m "Initial commit" -q
  # Create the untracked file
  echo "Untracked" > secret_data.txt
}
cleanup_sandbox() { :; }
