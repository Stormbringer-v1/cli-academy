#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
grep -q "KILLED:7777" "$ANSWER" || exit 1
exit 0