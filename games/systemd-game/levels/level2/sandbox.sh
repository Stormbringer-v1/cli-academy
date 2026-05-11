#!/usr/bin/env bash
set -euo pipefail
SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "systemdgame_level2.XXXXXX")"
    cd "$SANDBOX_DIR"
    create_user_unit "test-service.service" "[Unit]
Description=Test Service

[Service]
Type=oneshot
ExecStart=/bin/true
ExecStartPost=/bin/sleep 60

[Install]
WantedBy=default.target"
    systemctl_user daemon-reload
    systemctl_user start test-service
    touch answer.txt
    export SANDBOX_DIR
}
cleanup_sandbox() {
    systemctl_user stop test-service 2>/dev/null || true
    remove_user_unit test-service.service
    systemctl_user daemon-reload
}