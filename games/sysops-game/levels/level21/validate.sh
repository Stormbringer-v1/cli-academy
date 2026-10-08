#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
[[ -f "$ANSWER" ]] && grep -qE "^\d+$" "$ANSWER" || exit 1
exit 0