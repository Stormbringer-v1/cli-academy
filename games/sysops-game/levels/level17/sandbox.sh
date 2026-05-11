#!/usr/bin/env bash
set -euo pipefail

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sysopsgame_level17.XXXXXX")"
    cd "$SANDBOX_DIR"

    for i in $(seq 1 4); do
        bash -c 'while true; do :; done' &
        SYS_GAME_PIDS+=($!)
    done
    touch answer.txt

    export SANDBOX_DIR
}

cleanup_sandbox() {
    cleanup_sysops
}