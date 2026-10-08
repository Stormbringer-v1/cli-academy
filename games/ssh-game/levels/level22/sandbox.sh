#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l22" 22222
    wait_for_ssh "127.0.0.1" 22222
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_knock" 2246
    wait_for_ssh "127.0.0.1" 2246
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_knock"
    stop_ssh_container "cliacademy_ssh_l22"
    remove_network
}
