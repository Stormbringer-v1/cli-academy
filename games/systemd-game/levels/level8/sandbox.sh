#!/usr/bin/env bash

SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    create_user_unit "test-reload.service" "[Unit]
Description=Test Reload Service

[Service]
Type=oneshot
ExecStart=/bin/true

[Install]
WantedBy=default.target"
    systemctl_user daemon-reload
    touch answer.txt
}
cleanup_sandbox() {
    systemctl_user stop test-reload 2>/dev/null || true
    remove_user_unit test-reload.service
    systemctl_user daemon-reload
}