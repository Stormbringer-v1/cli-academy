#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ ! -f "$ANSWER_FILE" ]]; then
    exit 1
fi

grep -q "iptables -P INPUT DROP" "$ANSWER_FILE" || exit 1
grep -q "iptables -A INPUT -i lo" "$ANSWER_FILE" || exit 1
grep -q "ESTABLISHED,RELATED" "$ANSWER_FILE" || exit 1
grep -q -- "-dport 22" "$ANSWER_FILE" || exit 1

exit 0