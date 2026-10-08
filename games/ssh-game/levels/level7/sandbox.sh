#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l7" 2227
    wait_for_ssh "127.0.0.1" 2227
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    [[ -f ~/.ssh/id_ed25519 ]] || ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    start_ssh_container "cliacademy_ssh_agenttest" 2225
    wait_for_ssh "127.0.0.1" 2225
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_agenttest"
    stop_ssh_container "cliacademy_ssh_l7"
    remove_network
}
