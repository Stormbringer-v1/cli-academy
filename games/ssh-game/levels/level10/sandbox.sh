#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../ssh_common.sh"
setup_sandbox() {
    SANDBOX_DIR="$(mktemp -d -t "sshgame_level10.XXXXXX")"
    cd "$SANDBOX_DIR"
    create_network
    start_ssh_container "10" 22210
    wait_for_ssh "127.0.0.1" 22210
    touch "${SANDBOX_DIR}/answer.txt"
    export SANDBOX_DIR
}
cleanup_sandbox() {
    stop_ssh_container "10"
    rm -rf "${SANDBOX_DIR}"
}

mkdir -p ~/.ssh
chmod 700 ~/.ssh
start_ssh_container "fwdtest" 2230
wait_for_ssh "127.0.0.1" 2230
docker exec fwdtest sh -c "apt-get update -qq && apt-get install -y -qq apache2 > /dev/null 2>&1 && service apache2 start"
