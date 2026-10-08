#!/usr/bin/env bash
set -euo pipefail

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/validate_virsh_state.sh"

ANSWER_FILE="answer.txt"
if [[ ! -f "$ANSWER_FILE" ]]; then
    exit 1
fi

grep -q "virsh edit" "$ANSWER_FILE" || exit 1
grep -q "virsh snapshot" "$ANSWER_FILE" || exit 1
grep -q "virsh autostart" "$ANSWER_FILE" || exit 1

exit 0