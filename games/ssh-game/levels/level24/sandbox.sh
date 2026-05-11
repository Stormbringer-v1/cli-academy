#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../ssh_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sshgame_level24.XXXXXX")"
    cd "$SANDBOX_DIR"
    create_network
    start_ssh_container "24" 22224
    wait_for_ssh "127.0.0.1" 22224
    touch "${SANDBOX_DIR}/answer.txt"
    export SANDBOX_DIR
}
cleanup_sandbox() {
    stop_ssh_container "24"
    rm -rf "${SANDBOX_DIR}"
}

mkdir -p ~/.ssh
chmod 700 ~/.ssh
start_ssh_container "final_bastion" 2247
start_ssh_container "final_web" 2248
start_ssh_container "final_db" 2249
wait_for_ssh "127.0.0.1" 2247
wait_for_ssh "127.0.0.1" 2248
wait_for_ssh "127.0.0.1" 2249
