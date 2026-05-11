#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ -f "$ANSWER_FILE" ]] && grep -q "nft list ruleset" "$ANSWER_FILE"; then
    exit 0
fi
exit 1