#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ -f "$ANSWER_FILE" ]] && grep -q "iptables -L INPUT" "$ANSWER_FILE" && \
   grep -q "iptables -L OUTPUT" "$ANSWER_FILE" && \
   grep -q "iptables -L FORWARD" "$ANSWER_FILE"; then
    exit 0
fi
exit 1