#!/usr/bin/env bash
set -euo pipefail
ANSWER="${SANDBOX_DIR}/answer.txt"
[[ -f "$ANSWER" ]] && grep -q "timer" "$ANSWER" && exit 0 || exit 1