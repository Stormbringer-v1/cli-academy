#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "Hello World" > greeting.txt
  git add greeting.txt && git commit -q -m "Initial commit"
  git checkout -q -b feature
  echo "Hello Universe" > greeting.txt
  git add greeting.txt && git commit -q -m "Change greeting on feature"
  git checkout -q main
  echo "Hello Planet" > greeting.txt
  git add greeting.txt && git commit -q -m "Change greeting on main"
}
cleanup_sandbox() { :; }