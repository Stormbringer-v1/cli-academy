#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l0" 2220
    wait_for_ssh "127.0.0.1" 2220
    echo "SSH server ready on port 2220"
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_l0"
    remove_network
}
