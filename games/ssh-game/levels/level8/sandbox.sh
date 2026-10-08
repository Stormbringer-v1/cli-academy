#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l8" 2228
    wait_for_ssh "127.0.0.1" 2228
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_scptest" 2226
    wait_for_ssh "127.0.0.1" 2226
    docker exec cliacademy_ssh_scptest sh -c "mkdir -p /home/player && chown -R player:player /home/player"
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_scptest"
    stop_ssh_container "cliacademy_ssh_l8"
    remove_network
}
