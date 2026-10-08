#!/usr/bin/env bash
set -euo pipefail
# Check if debug.log is no longer in the index (staging area/current commit index)
if git ls-files | grep -q "^debug.log$"; then
  echo "debug.log is still being tracked by Git."
  exit 1
fi

# Check if debug.log is in .gitignore
if ! grep -q "^debug.log" .gitignore 2>/dev/null; then
  echo "debug.log is not listed in .gitignore."
  exit 1
fi

# Check if debug.log is actually ignored
if ! git check-ignore -q debug.log; then
  echo "debug.log is not ignored according to Git's ignore rules."
  exit 1
fi

# Also make sure the file still exists in the filesystem!
if [[ ! -f "debug.log" ]]; then
  echo "Error: You deleted debug.log! You were only supposed to stop tracking it."
  exit 1
fi

exit 0
