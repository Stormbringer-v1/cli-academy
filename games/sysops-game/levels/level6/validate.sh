#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
if [[ -f "$ANSWER" ]] && grep -q "SIGCONT" "$ANSWER"; then
    exit 0
fi
exit 1