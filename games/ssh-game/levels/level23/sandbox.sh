#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../ssh_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sshgame_level23.XXXXXX")"
    cd "$SANDBOX_DIR"
    create_network
    start_ssh_container "23" 22223
    wait_for_ssh "127.0.0.1" 22223
    touch "${SANDBOX_DIR}/answer.txt"
    export SANDBOX_DIR
}
cleanup_sandbox() {
    stop_ssh_container "23"
    rm -rf "${SANDBOX_DIR}"
}

mkdir -p ~/.ssh
chmod 700 ~/.ssh
start_ssh_container "bastion_main" 2230
start_ssh_container "app1_main" 2231
start_ssh_container "app2_main" 2232
wait_for_ssh "127.0.0.1" 2230
wait_for_ssh "127.0.0.1" 2231
wait_for_ssh "127.0.0.1" 2232
