#!/usr/bin/env bash

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    spawn_rogue stubborn_process trap
    touch answer.txt
}

cleanup_sandbox() {
    cleanup_sysops
}