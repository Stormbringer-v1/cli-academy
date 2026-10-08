#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "base" > file.txt
  git add file.txt && git commit -q -m "Base commit"
  git checkout -q -b feature
  echo "feature1" > feature1.txt && git add feature1.txt && git commit -q -m "Feature 1"
  echo "feature2" > feature2.txt && git add feature2.txt && git commit -q -m "Feature 2"
  git checkout -q main
  echo "main2" > main.txt && git add main.txt && git commit -q -m "Main 2"
}
cleanup_sandbox() { :; }
