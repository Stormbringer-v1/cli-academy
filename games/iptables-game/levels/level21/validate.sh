#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ -f "$ANSWER_FILE" ]] && grep -q "nft add table" "$ANSWER_FILE" && \
   grep -q "nft add chain" "$ANSWER_FILE"; then
    exit 0
fi
exit 1