#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ ! -f "$ANSWER_FILE" ]]; then
    exit 1
fi

grep -q "MASQUERADE" "$ANSWER_FILE" || exit 1
grep -q "DNAT" "$ANSWER_FILE" || exit 1
grep -q "limit" "$ANSWER_FILE" || exit 1
grep -q "LOGGING" "$ANSWER_FILE" || exit 1

exit 0