#!/usr/bin/env bash
setup_sandbox() {
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Player"
  git config user.email "player@cli-academy.local"
  # Commit 7 introduces the line "BAD"; it stays in file.txt in commits 8 to 10.
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if [[ "$i" == 7 ]]; then echo "BAD" >> file.txt; else echo "line $i" >> file.txt; fi
    git add file.txt
    git commit -q -m "Commit $i"
  done
  # A side branch with a clean commit (made before the bad one) to cherry-pick.
  git checkout -q -b clean-fix main~4
  echo "fix" > fix.txt
  git add fix.txt
  git commit -q -m "Clean fix"
  git checkout -q main
}
cleanup_sandbox() { :; }
