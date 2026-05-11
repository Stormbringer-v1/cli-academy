#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../ssh_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sshgame_level13.XXXXXX")"
    cd "$SANDBOX_DIR"
    create_network
    start_ssh_container "13" 22213
    wait_for_ssh "127.0.0.1" 22213
    touch "${SANDBOX_DIR}/answer.txt"
    export SANDBOX_DIR
}
cleanup_sandbox() {
    stop_ssh_container "13"
    rm -rf "${SANDBOX_DIR}"
}

mkdir -p ~/.ssh
chmod 700 ~/.ssh
start_ssh_container "bastion" 2233
start_ssh_container "internal" 2234
wait_for_ssh "127.0.0.1" 2233
wait_for_ssh "127.0.0.1" 2234
