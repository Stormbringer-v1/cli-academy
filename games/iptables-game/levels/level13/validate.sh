#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ -f "$ANSWER_FILE" ]] && grep -q "8000:8100" "$ANSWER_FILE"; then
    exit 0
fi
exit 1