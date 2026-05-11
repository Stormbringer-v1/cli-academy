#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "main" > file.txt && git add file.txt && git commit -q -m "Initial"
  git checkout -q -b feature1 && echo "f1" >> file.txt && git add file.txt && git commit -q -m "Feature 1"
  git checkout -q main && git checkout -q -b feature2 && echo "f2" >> file.txt && git add file.txt && git commit -q -m "Feature 2"
  git checkout -q main && git checkout -q -b feature3 && echo "f3" >> file.txt && git add file.txt && git commit -q -m "Feature 3"
  git checkout -q main
}
cleanup_sandbox() { :; }