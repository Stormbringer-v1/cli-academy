#!/usr/bin/env bash

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    echo "secret_data" > mystery_file.txt
    bash -c 'while true; do cat mystery_file.txt > /dev/null; sleep 1; done' &
    SYS_GAME_PIDS+=($!)
    echo "mystery_file.txt" > "${SANDBOX_DIR}/expected.txt"
    touch answer.txt
}

cleanup_sandbox() {
    cleanup_sysops
}