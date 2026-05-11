#!/usr/bin/env bash
set -euo pipefail
SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "systemdgame_level9.XXXXXX")"
    cd "$SANDBOX_DIR"
    cat > example.service <<'EOF'
[Unit]
Description=Example Service
Documentation=man:myservice(1)
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/example-service --foreground
ExecStop=/usr/bin/example-service --stop
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF
    touch answer.txt
    export SANDBOX_DIR
}
cleanup_sandbox() {
    :
}