#!/usr/bin/env bash
set -euo pipefail

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/validate_virsh_state.sh"

ANSWER_FILE="answer.txt"
if [[ ! -f "$ANSWER_FILE" ]]; then
    exit 1
fi

grep -q "virsh pool-" "$ANSWER_FILE" || exit 1
grep -q "virsh vol-" "$ANSWER_FILE" || exit 1
grep -q "virsh net-" "$ANSWER_FILE" || exit 1
grep -q "virsh define" "$ANSWER_FILE" || exit 1
grep -q "virsh attach" "$ANSWER_FILE" || exit 1

exit 0