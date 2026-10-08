#!/usr/bin/env bash
setup_sandbox() {
  mkdir repo
  git -C repo init -q
  git -C repo symbolic-ref HEAD refs/heads/main
  git -C repo config user.name "Player"
  git -C repo config user.email "player@cli-academy.local"
  echo "main" > repo/file.txt && git -C repo add file.txt && git -C repo commit -q -m "Initial commit"
  git -C repo checkout -q -b feature
  echo "feature" >> repo/file.txt && git -C repo add file.txt && git -C repo commit -q -m "Feature commit"
  git -C repo checkout -q main
}
cleanup_sandbox() { :; }
