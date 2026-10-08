#!/usr/bin/env bash
set -euo pipefail
ANSWER="${SANDBOX_DIR}/answer.txt"
[[ -f "$ANSWER" ]] && grep -qE "enabled|disabled" "$ANSWER" && exit 0 || exit 1