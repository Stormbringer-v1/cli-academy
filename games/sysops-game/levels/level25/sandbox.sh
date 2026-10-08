#!/usr/bin/env bash

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    spawn_listener fuser_target 7777
    touch answer.txt
}

cleanup_sandbox() {
    cleanup_sysops
}