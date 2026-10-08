#!/usr/bin/env bash

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SSH_GAME_ROOT}/ssh_common.sh"

setup_sandbox() {
    create_network
    start_ssh_container "cliacademy_ssh_l10" 22210
    wait_for_ssh "127.0.0.1" 22210
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    start_ssh_container "cliacademy_ssh_fwdtest" 2230
    wait_for_ssh "127.0.0.1" 2230
    docker exec cliacademy_ssh_fwdtest sh -c "apt-get update -qq && apt-get install -y -qq apache2 > /dev/null 2>&1 && service apache2 start"
    touch answer.txt
}

cleanup_sandbox() {
    stop_ssh_container "cliacademy_ssh_fwdtest"
    stop_ssh_container "cliacademy_ssh_l10"
    remove_network
}
