#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "main" > file.txt && git add file.txt && git commit -q -m "Initial commit"
  mkdir -p /tmp/submod || true
  echo "sub" > /tmp/submod/file.txt
  cd /tmp/submod && git init -q && git add file.txt && git commit -q -m "Submodule commit"
  cd - > /dev/null
}
cleanup_sandbox() { rm -rf /tmp/submod 2>/dev/null; }