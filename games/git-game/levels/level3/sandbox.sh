#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "Hello, World!" > hello.txt
  git add hello.txt
}
cleanup_sandbox() { :; }
