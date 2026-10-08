#!/usr/bin/env bash
set -euo pipefail
# Observe the player's work; never perform it. Command output is captured first so that
# no "cmd | grep -q" pipeline can fail on SIGPIPE under pipefail.

# 1. bad_commit.txt holds (at least 7 characters of) the hash of Commit 7, which introduced BAD.
if [[ ! -f bad_commit.txt ]]; then
  echo "bad_commit.txt not found."
  exit 1
fi
hash="$(tr -d '[:space:]' < bad_commit.txt)"
expected="$(git log main --format=%H --grep='^Commit 7$' -n 1)"
if [[ ${#hash} -lt 7 || -z "$expected" || "$expected" != "$hash"* ]]; then
  echo "bad_commit.txt does not name the commit that introduced BAD."
  exit 1
fi

# 2. v1.0 is an annotated tag.
if [[ "$(git cat-file -t v1.0 2>/dev/null || true)" != "tag" ]]; then
  echo "Tag v1.0 not found."
  exit 1
fi

# 3. The clean commit of branch clean-fix was cherry-picked onto main: git cherry marks
#    commits that exist upstream as a copy with "-", and the others with "+".
cherry="$(git cherry main clean-fix 2>/dev/null || true)"
if [[ -z "$cherry" ]] || grep -q '^+' <<<"$cherry"; then
  echo "The clean commit from clean-fix was not cherry-picked onto main."
  exit 1
fi
exit 0
