#!/usr/bin/env bash
set -euo pipefail
SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "systemdgame_level17.XXXXXX")"
    cd "$SANDBOX_DIR"
    cat > my-app.env <<'EOF'
APP_NAME=test
APP_MODE=production
EOF
    touch answer.txt
    export SANDBOX_DIR
}
cleanup_sandbox() {
    systemctl_user stop env-app 2>/dev/null || true
    remove_user_unit env-app.service
    systemctl_user daemon-reload
}