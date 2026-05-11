#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ -f "$ANSWER_FILE" ]] && grep -q "iptables -P INPUT DROP" "$ANSWER_FILE"; then
    exit 0
fi
exit 1