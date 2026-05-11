#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
grep -q "BEFORE:" "$ANSWER" || exit 1
grep -q "AFTER:" "$ANSWER" || exit 1
exit 0