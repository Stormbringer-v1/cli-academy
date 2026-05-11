#!/usr/bin/env bash
set -euo pipefail
ANSWER="${SANDBOX_DIR}/answer.txt"
[[ -f "$ANSWER" ]] && grep -q "Environment" "$ANSWER" && exit 0 || exit 1