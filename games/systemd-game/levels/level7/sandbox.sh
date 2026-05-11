#!/usr/bin/env bash
set -euo pipefail
SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "systemdgame_level7.XXXXXX")"
    cd "$SANDBOX_DIR"
    create_user_unit "test-mask.service" "[Unit]
Description=Test Mask Service

[Service]
Type=oneshot
ExecStart=/bin/true

[Install]
WantedBy=default.target"
    systemctl_user daemon-reload
    touch answer.txt
    export SANDBOX_DIR
}
cleanup_sandbox() {
    systemctl_user unmask test-mask 2>/dev/null || true
    remove_user_unit test-mask.service
    systemctl_user daemon-reload
}