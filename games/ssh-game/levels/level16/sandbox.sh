#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l16" 22216
    wait_for_ssh "127.0.0.1" 22216
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_restrict" 2237
    wait_for_ssh "127.0.0.1" 2237
    docker exec cliacademy_ssh_restrict sh -c "apt-get update -qq && apt-get install -y -qq sudo > /dev/null 2>&1"
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_restrict"
    stop_ssh_container "cliacademy_ssh_l16"
    remove_network
}
