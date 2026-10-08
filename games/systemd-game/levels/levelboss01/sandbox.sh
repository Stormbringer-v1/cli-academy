#!/usr/bin/env bash

SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    mkdir -p broken-app-dir
    cat > broken-app.sh <<'SCRIPT'
#!/bin/bash
echo "App started"
sleep 60
SCRIPT
    chmod +x broken-app.sh
    create_user_unit "broken-app.service" "[Unit]
Description=Broken Application

[Service]
Type=oneshot
ExecStart=/nonexistent/path/broken-app.sh
WorkingDirectory=SANDBOX_DIR_PLACEHOLDER

[Install]
WantedBy=default.target"
    sed -i "s|SANDBOX_DIR_PLACEHOLDER|${SANDBOX_DIR}|g" "${HOME}/.config/systemd/user/broken-app.service" 2>/dev/null || true
    systemctl_user daemon-reload
    touch answer.txt
}
cleanup_sandbox() {
    systemctl_user stop broken-app 2>/dev/null || true
    remove_user_unit broken-app.service
    systemctl_user daemon-reload
}