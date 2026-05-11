#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
[[ -f "$ANSWER" ]] && grep -q "CPU" "$ANSWER" || exit 1
grep -q "lock" "$ANSWER" || exit 1
grep -q "9999" "$ANSWER" || exit 1
exit 0