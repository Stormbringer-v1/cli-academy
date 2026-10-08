#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l9" 2229
    wait_for_ssh "127.0.0.1" 2229
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_sftptest" 2227
    wait_for_ssh "127.0.0.1" 2227
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_sftptest"
    stop_ssh_container "cliacademy_ssh_l9"
    remove_network
}
