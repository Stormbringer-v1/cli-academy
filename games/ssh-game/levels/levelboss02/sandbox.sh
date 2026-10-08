#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_lboss02" 22292
    wait_for_ssh "127.0.0.1" 22292
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_boss2_bastion" 2239
    start_ssh_container "cliacademy_ssh_boss2_web" 2240
    start_ssh_container "cliacademy_ssh_boss2_db" 2241
    wait_for_ssh "127.0.0.1" 2239
    wait_for_ssh "127.0.0.1" 2240
    wait_for_ssh "127.0.0.1" 2241
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_boss2_db"
    stop_ssh_container "cliacademy_ssh_boss2_web"
    stop_ssh_container "cliacademy_ssh_boss2_bastion"
    stop_ssh_container "cliacademy_ssh_lboss02"
    remove_network
}
