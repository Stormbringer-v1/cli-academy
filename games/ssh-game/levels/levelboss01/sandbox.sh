#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_lboss01" 22291
    wait_for_ssh "127.0.0.1" 22291
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_boss1a" 2228
    start_ssh_container "cliacademy_ssh_boss1b" 2229
    wait_for_ssh "127.0.0.1" 2228
    wait_for_ssh "127.0.0.1" 2229
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_boss1b"
    stop_ssh_container "cliacademy_ssh_boss1a"
    stop_ssh_container "cliacademy_ssh_lboss01"
    remove_network
}
