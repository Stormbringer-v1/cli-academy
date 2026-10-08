#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l24" 22224
    wait_for_ssh "127.0.0.1" 22224
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_final_bastion" 2247
    start_ssh_container "cliacademy_ssh_final_web" 2248
    start_ssh_container "cliacademy_ssh_final_db" 2249
    wait_for_ssh "127.0.0.1" 2247
    wait_for_ssh "127.0.0.1" 2248
    wait_for_ssh "127.0.0.1" 2249
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_final_db"
    stop_ssh_container "cliacademy_ssh_final_web"
    stop_ssh_container "cliacademy_ssh_final_bastion"
    stop_ssh_container "cliacademy_ssh_l24"
    remove_network
}
