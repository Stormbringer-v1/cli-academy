#!/usr/bin/env bash
set -euo pipefail
# Observe only. The graph must show the branching (--all so the feature branch is
# included), and branch_commits.txt must hold the number of commits on 'feature'.
graph="$(git log --graph --oneline --all)"
if ! grep -q "|" <<<"$graph"; then
  echo "Git graph does not show branching."
  exit 1
fi
expected="$(git rev-list --count feature 2>/dev/null || true)"
actual=""
if [[ -f branch_commits.txt ]]; then
  actual="$(tr -d '[:space:]' < branch_commits.txt)"
fi
if [[ -z "$expected" || "$actual" != "$expected" ]]; then
  echo "branch_commits.txt must hold the number of commits on the 'feature' branch."
  exit 1
fi
exit 0
