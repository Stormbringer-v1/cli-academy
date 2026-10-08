#!/usr/bin/env bash
set -euo pipefail

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

ANSWER="${SANDBOX_DIR}/answer.txt"
PID_FILE="${SANDBOX_DIR}/.rogue_sleep.pid"

if [[ -f "$PID_FILE" ]] && [[ -f "$ANSWER" ]]; then
    EXPECTED=$(cat "$PID_FILE")
    ACTUAL=$(cat "$ANSWER")
    if [[ "$EXPECTED" == "$ACTUAL" ]]; then
        exit 0
    fi
fi
exit 1