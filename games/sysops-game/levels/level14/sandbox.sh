#!/usr/bin/env bash
set -euo pipefail

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sysopsgame_level14.XXXXXX")"
    cd "$SANDBOX_DIR"

    bash -c 'sleep 99999' &
    SYS_GAME_PIDS+=($!)
    echo "bash" > "${SANDBOX_DIR}/expected_cmd.txt"
    touch answer.txt

    export SANDBOX_DIR
}

cleanup_sandbox() {
    cleanup_sysops
}