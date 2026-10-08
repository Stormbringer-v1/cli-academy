#!/usr/bin/env bash
set -euo pipefail

ANSWER="${SANDBOX_DIR}/answer.txt"
[[ -f "$ANSWER" ]] && grep -q "PPid" "$ANSWER" || exit 1
grep -q "State" "$ANSWER" || exit 1
grep -q "Vm" "$ANSWER" || exit 1
exit 0