#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ -f "$ANSWER_FILE" ]] && grep -q "conntrack" "$ANSWER_FILE" && grep -q "ESTABLISHED" "$ANSWER_FILE"; then
    exit 0
fi
exit 1