#!/usr/bin/env bash
set -euo pipefail

ANSWER_FILE="answer.txt"
if [[ -f "$ANSWER_FILE" ]] && grep -q "virsh pool-define" "$ANSWER_FILE"; then
    exit 0
fi
exit 1