#!/usr/bin/env bash

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    for _ in 1 2 3 4; do
        bash -c 'while true; do :; done' &
        SYS_GAME_PIDS+=($!)
    done
    touch answer.txt
}

cleanup_sandbox() {
    cleanup_sysops
}