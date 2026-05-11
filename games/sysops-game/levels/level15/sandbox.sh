#!/usr/bin/env bash
set -euo pipefail

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sysopsgame_level15.XXXXXX")"
    cd "$SANDBOX_DIR"

    bash -c 'exec {fd1}>/dev/null {fd2}>/dev/null {fd3}>/dev/null; sleep 99999' &
    SYS_GAME_PIDS+=($!)
    touch answer.txt

    export SANDBOX_DIR
}

cleanup_sandbox() {
    cleanup_sysops
}