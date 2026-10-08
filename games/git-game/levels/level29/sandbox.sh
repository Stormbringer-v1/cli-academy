#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "main" > file.txt && git add file.txt && git commit -q -m "Initial commit"
  mkdir submod
  git -C submod init -q
  git -C submod symbolic-ref HEAD refs/heads/main
  git -C submod config user.name "Player"
  git -C submod config user.email "player@cli-academy.local"
  echo "sub" > submod/file.txt
  git -C submod add file.txt && git -C submod commit -q -m "Submodule commit"
  echo "/submod/" >> .git/info/exclude
}
cleanup_sandbox() { :; }
