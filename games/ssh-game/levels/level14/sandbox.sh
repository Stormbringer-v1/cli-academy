#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l14" 22214
    wait_for_ssh "127.0.0.1" 22214
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_multiplex" 2235
    wait_for_ssh "127.0.0.1" 2235
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_multiplex"
    stop_ssh_container "cliacademy_ssh_l14"
    remove_network
}
