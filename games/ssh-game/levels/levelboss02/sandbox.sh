#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../ssh_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sshgame_levelboss02.XXXXXX")"
    cd "$SANDBOX_DIR"
    create_network
    start_ssh_container "boss02" 222boss02
    wait_for_ssh "127.0.0.1" 222boss02
    touch "${SANDBOX_DIR}/answer.txt"
    export SANDBOX_DIR
}
cleanup_sandbox() {
    stop_ssh_container "boss02"
    rm -rf "${SANDBOX_DIR}"
}

mkdir -p ~/.ssh
chmod 700 ~/.ssh
start_ssh_container "boss2_bastion" 2239
start_ssh_container "boss2_web" 2240
start_ssh_container "boss2_db" 2241
wait_for_ssh "127.0.0.1" 2239
wait_for_ssh "127.0.0.1" 2240
wait_for_ssh "127.0.0.1" 2241
