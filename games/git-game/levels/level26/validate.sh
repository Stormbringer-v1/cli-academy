#!/usr/bin/env bash
set -euo pipefail
# bad_commit.txt must hold (at least 7 characters of) the hash of the commit that
# introduced "BAD": Commit 3.
hash=""
if [[ -f bad_commit.txt ]]; then
  hash="$(tr -d '[:space:]' < bad_commit.txt)"
fi
if [[ ${#hash} -lt 7 ]]; then
  echo "Bad commit hash not written to bad_commit.txt"
  exit 1
fi
expected="$(git log main --format=%H --grep='^Commit 3$' -n 1)"
if [[ -z "$expected" || "$expected" != "$hash"* ]]; then
  echo "bad_commit.txt does not name the commit that introduced BAD."
  exit 1
fi
exit 0
