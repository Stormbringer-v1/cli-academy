#!/usr/bin/env bash
set -euo pipefail

SYS_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYS_GAME_ROOT}/sysops_common.sh"

setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sysopsgame_level25.XXXXXX")"
    cd "$SANDBOX_DIR"

    spawn_listener fuser_target 7777
    touch answer.txt

    export SANDBOX_DIR
}

cleanup_sandbox() {
    cleanup_sysops
}