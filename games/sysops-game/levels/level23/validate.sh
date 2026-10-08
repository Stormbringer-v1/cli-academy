#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
grep -q "8888" "$ANSWER" || exit 1
exit 0