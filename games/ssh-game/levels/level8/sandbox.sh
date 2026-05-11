#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../ssh_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sshgame_level8.XXXXXX")"
    cd "$SANDBOX_DIR"
    create_network
    start_ssh_container "8" 2228
    wait_for_ssh "127.0.0.1" 2228
    touch "${SANDBOX_DIR}/answer.txt"
    export SANDBOX_DIR
}
cleanup_sandbox() {
    stop_ssh_container "8"
    rm -rf "${SANDBOX_DIR}"
}

mkdir -p ~/.ssh
chmod 700 ~/.ssh
start_ssh_container "scptest" 2226
wait_for_ssh "127.0.0.1" 2226
docker exec scptest sh -c "mkdir -p /home/player && chown -R player:player /home/player"
