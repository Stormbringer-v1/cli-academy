#!/usr/bin/env bash

SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    cat > my-app.sh <<'SCRIPT'
#!/bin/bash
echo "Hello from my-app"
SCRIPT
    chmod +x my-app.sh
    touch answer.txt
}
cleanup_sandbox() {
    systemctl_user stop my-app 2>/dev/null || true
    systemctl_user disable my-app 2>/dev/null || true
    remove_user_unit my-app.service
    systemctl_user daemon-reload
}