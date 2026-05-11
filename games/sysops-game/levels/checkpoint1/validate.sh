#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
grep -q "SIGTERM" "$ANSWER" || exit 1
grep -q "SIGKILL" "$ANSWER" || exit 1
grep -q "STOP" "$ANSWER" || exit 1
grep -q "CONT" "$ANSWER" || exit 1
grep -q "stopped" "$ANSWER" || exit 1
exit 0