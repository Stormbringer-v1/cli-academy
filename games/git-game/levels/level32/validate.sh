#!/usr/bin/env bash
set -euo pipefail
# secret.txt must be gone from the history of every branch and tag. filter-branch keeps
# the old history under refs/original, so look at --branches --tags instead of --all.
# The output is captured first: a "cmd | grep -q" pipeline can fail on SIGPIPE.
touching="$(git rev-list --branches --tags -- secret.txt)"
if [[ -n "$touching" ]]; then
  echo "secret.txt still in history."
  exit 1
fi
exit 0
