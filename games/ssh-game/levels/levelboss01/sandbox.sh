#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../ssh_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sshgame_levelboss01.XXXXXX")"
    cd "$SANDBOX_DIR"
    create_network
    start_ssh_container "boss01" 222boss01
    wait_for_ssh "127.0.0.1" 222boss01
    touch "${SANDBOX_DIR}/answer.txt"
    export SANDBOX_DIR
}
cleanup_sandbox() {
    stop_ssh_container "boss01"
    rm -rf "${SANDBOX_DIR}"
}

mkdir -p ~/.ssh
chmod 700 ~/.ssh
start_ssh_container "boss1a" 2228
start_ssh_container "boss1b" 2229
wait_for_ssh "127.0.0.1" 2228
wait_for_ssh "127.0.0.1" 2229
