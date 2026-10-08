#!/usr/bin/env bash

SYSTEMD_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SYSTEMD_GAME_ROOT}/systemd_common.sh"
setup_sandbox() {
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
}
cleanup_sandbox() {
    :
}