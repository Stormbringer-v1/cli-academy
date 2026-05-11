#!/usr/bin/env bash
set -euo pipefail

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sysopsgame_level9.XXXXXX")"
    cd "$SANDBOX_DIR"

    bash -c 'sleep 99999' &
    local PARENT=$!
    sleep 99999 &
    local CHILD=$!
    echo "$PARENT:$CHILD" > "${SANDBOX_DIR}/answer.txt"
    SYS_GAME_PIDS+=($PARENT $CHILD)

    export SANDBOX_DIR
}

cleanup_sandbox() {
    cleanup_sysops
}