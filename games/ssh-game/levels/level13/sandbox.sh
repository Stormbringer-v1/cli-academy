#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l13" 22213
    wait_for_ssh "127.0.0.1" 22213
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_bastion" 2233
    start_ssh_container "cliacademy_ssh_internal" 2234
    wait_for_ssh "127.0.0.1" 2233
    wait_for_ssh "127.0.0.1" 2234
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_internal"
    stop_ssh_container "cliacademy_ssh_bastion"
    stop_ssh_container "cliacademy_ssh_l13"
    remove_network
}
