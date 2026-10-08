#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l23" 22223
    wait_for_ssh "127.0.0.1" 22223
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_bastion_main" 2230
    start_ssh_container "cliacademy_ssh_app1_main" 2231
    start_ssh_container "cliacademy_ssh_app2_main" 2232
    wait_for_ssh "127.0.0.1" 2230
    wait_for_ssh "127.0.0.1" 2231
    wait_for_ssh "127.0.0.1" 2232
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_app2_main"
    stop_ssh_container "cliacademy_ssh_app1_main"
    stop_ssh_container "cliacademy_ssh_bastion_main"
    stop_ssh_container "cliacademy_ssh_l23"
    remove_network
}
