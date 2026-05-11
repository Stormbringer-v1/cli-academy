#!/usr/bin/env bash
set -euo pipefail

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sysopsgame_level20.XXXXXX")"
    cd "$SANDBOX_DIR"

    touch file1.txt file2.txt file3.txt
    bash -c 'exec 3>file1.txt 4>file2.txt 5>file3.txt; sleep 99999' &
    SYS_GAME_PIDS+=($!)
    touch answer.txt

    export SANDBOX_DIR
}

cleanup_sandbox() {
    cleanup_sysops
}