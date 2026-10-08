#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
grep -q "CPU-BOUND" "$ANSWER" || exit 1
grep -q "HEALTHY" "$ANSWER" || exit 1
grep -q "IO-BOUND" "$ANSWER" || exit 1
exit 0