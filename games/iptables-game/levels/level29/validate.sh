#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ ! -f "$ANSWER_FILE" ]]; then
    exit 1
fi

grep -q "iptables -D" "$ANSWER_FILE" || exit 1
grep -q "iptables -P INPUT DROP" "$ANSWER_FILE" || exit 1

exit 0