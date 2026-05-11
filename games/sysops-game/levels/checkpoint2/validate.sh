#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
grep -q "1234" "$ANSWER" || exit 1
grep -q "sleeping" "$ANSWER" || exit 1
grep -q "8192" "$ANSWER" || exit 1
grep -q "worker" "$ANSWER" || exit 1
exit 0