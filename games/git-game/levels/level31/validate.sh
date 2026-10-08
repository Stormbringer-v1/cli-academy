#!/usr/bin/env bash
set -euo pipefail
hook_path=".git/hooks/pre-commit"
if [[ ! -f "$hook_path" ]]; then
  echo "Pre-commit hook not found."
  exit 1
fi
if [[ ! -x "$hook_path" ]]; then
  echo "Hook is not executable."
  exit 1
fi
# Test the hook rejects WIP
if git commit -m "WIP test" 2>/dev/null; then
  echo "Hook did not block WIP commit."
  exit 1
fi
exit 0