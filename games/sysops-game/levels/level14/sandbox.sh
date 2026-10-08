#!/usr/bin/env bash

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    bash -c 'sleep 99999' &
    SYS_GAME_PIDS+=($!)
    echo "bash" > "${SANDBOX_DIR}/expected_cmd.txt"
    touch answer.txt
}

cleanup_sandbox() {
    cleanup_sysops
}