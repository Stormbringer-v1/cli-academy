#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  # Commit 3 introduces the line "BAD"; it stays in file.txt in commits 4 and 5.
  for i in 1 2 3 4 5; do
    if [[ "$i" == 3 ]]; then echo "BAD" >> file.txt; else echo "$i" >> file.txt; fi
    git add file.txt && git commit -q -m "Commit $i"
  done
}
cleanup_sandbox() { :; }
