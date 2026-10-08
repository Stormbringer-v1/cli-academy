#!/usr/bin/env bash
# Level 1 setup: pre-initialize a git repo so user can focus on git config

setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  echo "This is a test file." > readme.txt
}

cleanup_sandbox() {
  :
}
