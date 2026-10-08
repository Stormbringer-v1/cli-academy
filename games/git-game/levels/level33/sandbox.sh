#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "main" > file.txt && git add file.txt && git commit -q -m "Initial"
  git checkout -q -b feature1 && echo "f1" > f1.txt && git add f1.txt && git commit -q -m "Feature 1"
  git checkout -q main && git checkout -q -b feature2 && echo "f2" > f2.txt && git add f2.txt && git commit -q -m "Feature 2"
  git checkout -q main && git checkout -q -b feature3 && echo "f3" > f3.txt && git add f3.txt && git commit -q -m "Feature 3"
  git checkout -q main
}
cleanup_sandbox() { :; }