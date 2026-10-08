#!/usr/bin/env bash
set -euo pipefail
GIT_DIR="${GIT_DIR:-.}"
cd "$GIT_DIR" 2>/dev/null || cd .

feature_tip=$(git -C "$GIT_DIR" rev-parse feature 2>/dev/null || true)
main_tip=$(git -C "$GIT_DIR" rev-parse HEAD 2>/dev/null || true)

if [[ -z "$feature_tip" || -z "$main_tip" ]]; then
  echo "Could not read branch tips."
  exit 1
fi

if [[ "$feature_tip" == "$main_tip" ]]; then
  exit 0
fi

echo "Feature has not been fast-forward merged into main."
exit 1
