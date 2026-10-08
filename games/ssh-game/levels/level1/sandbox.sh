#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l1" 2221
    wait_for_ssh "127.0.0.1" 2221
    echo "SSH server ready on port 2221"
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_l1"
    remove_network
}
