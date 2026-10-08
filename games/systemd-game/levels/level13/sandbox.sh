#!/usr/bin/env bash

SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    touch answer.txt
}
cleanup_sandbox() {
    :
}