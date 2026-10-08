#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  echo "secret" > secret.txt
  git add secret.txt && git commit -q -m "Add secret"
  echo "public" > public.txt
  git add public.txt && git commit -q -m "Add public file"
}
cleanup_sandbox() { :; }