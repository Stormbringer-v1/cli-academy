#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  
  # Commit 1: Correct code
  echo 'print("Hello, SnapSecurity Academy!")' > code.py
  git add code.py
  git commit -m "First commit: correct code" -q
  
  # Commit 2: Bug introduced
  echo 'print("Hello, Hackers!")' > code.py
  git add code.py
  git commit -m "Second commit: bug introduced" -q
}
cleanup_sandbox() { :; }
