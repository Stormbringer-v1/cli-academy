#!/usr/bin/env bash

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    bash -c 'sleep 99999' &
    local PARENT=$!
    sleep 99999 &
    local CHILD=$!
    echo "$PARENT:$CHILD" > "${SANDBOX_DIR}/answer.txt"
    SYS_GAME_PIDS+=("$PARENT" "$CHILD")
}

cleanup_sandbox() {
    cleanup_sysops
}