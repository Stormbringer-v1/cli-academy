#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  
  echo "Important content" > README.md
  git add README.md
  git commit -m "Initial commti" -q
}
cleanup_sandbox() { :; }
