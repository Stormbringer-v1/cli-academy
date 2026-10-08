#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l6" 2226
    wait_for_ssh "127.0.0.1" 2226
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_hosttest" 2224
    wait_for_ssh "127.0.0.1" 2224
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_hosttest"
    stop_ssh_container "cliacademy_ssh_l6"
    remove_network
}
