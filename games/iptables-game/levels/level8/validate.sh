#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ -f "$ANSWER_FILE" ]] && grep -q "iptables-save" "$ANSWER_FILE" && \
   grep -q "iptables-restore" "$ANSWER_FILE"; then
    exit 0
fi
exit 1