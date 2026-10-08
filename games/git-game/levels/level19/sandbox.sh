#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "content" > file.txt && git add file.txt && git commit -q -m "Initial commit"
  git clone -q --bare . upstream.git
  echo "/upstream.git/" >> .git/info/exclude
}
cleanup_sandbox() { :; }
