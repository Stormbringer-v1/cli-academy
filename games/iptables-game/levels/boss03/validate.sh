#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ ! -f "$ANSWER_FILE" ]]; then
    exit 1
fi

grep -q "nft add table" "$ANSWER_FILE" || exit 1
grep -q "nft add chain" "$ANSWER_FILE" || exit 1
grep -q "counter" "$ANSWER_FILE" || exit 1
grep -q "masquerade" "$ANSWER_FILE" || exit 1

exit 0