#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ -f "$ANSWER_FILE" ]] && grep -q "multiport" "$ANSWER_FILE" && grep -q "22,80,443" "$ANSWER_FILE"; then
    exit 0
fi
exit 1