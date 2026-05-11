#!/usr/bin/env bash
set -euo pipefail
SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "systemdgame_level19.XXXXXX")"
    cd "$SANDBOX_DIR"
    touch answer.txt
    export SANDBOX_DIR
}
cleanup_sandbox() {
    :
}