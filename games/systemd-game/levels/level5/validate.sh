#!/usr/bin/env bash
set -euo pipefail
ANSWER="${SANDBOX_DIR}/answer.txt"
[[ -f "$ANSWER" ]] && grep -qE '^[0-9]+$' "$ANSWER" && exit 0 || exit 1