#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l3" 2223
    wait_for_ssh "127.0.0.1" 2223
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_keytest" 2222
    wait_for_ssh "127.0.0.1" 2222
    docker exec cliacademy_ssh_keytest sh -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo 'player:cliacademy' | chpasswd"
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_keytest"
    stop_ssh_container "cliacademy_ssh_l3"
    remove_network
}
