#!/usr/bin/env bash

SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    create_user_unit "test.service" "[Unit]
Description=Test Service

[Service]
Type=oneshot
ExecStart=/bin/true

[Install]
WantedBy=default.target"
    create_user_unit "test.timer" "[Unit]
Description=Test Timer

[Timer]
OnCalendar=*-*-*:*:00

[Install]
WantedBy=timers.target"
    systemctl_user daemon-reload
    systemctl_user start test.timer
    touch answer.txt
}
cleanup_sandbox() {
    systemctl_user stop test.timer 2>/dev/null || true
    systemctl_user stop test.service 2>/dev/null || true
    remove_user_unit test.timer
    remove_user_unit test.service
    systemctl_user daemon-reload
}