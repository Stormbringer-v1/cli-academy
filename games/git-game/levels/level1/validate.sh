#!/usr/bin/env bash
# Validate: git config user.name and user.email are set in the local repo
set -euo pipefail

NAME=$(git config --local user.name 2>/dev/null || echo "")
EMAIL=$(git config --local user.email 2>/dev/null || echo "")

if [[ -z "$NAME" ]]; then
  echo "user.name is not set."
  exit 1
fi

if [[ -z "$EMAIL" ]]; then
  echo "user.email is not set."
  exit 1
fi

exit 0
