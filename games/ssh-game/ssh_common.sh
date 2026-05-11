#!/usr/bin/env bash
set -euo pipefail

SSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAME_PREFIX="cliacademy_"
DOCKER_NETWORK="${GAME_PREFIX}net"

ssh_game_init() {
    if ! command -v ssh &>/dev/null; then
        echo "❌ Error: ssh client not found."
        echo "   OpenSSH client is required but not installed."
        exit 1
    fi

    if ! command -v docker &>/dev/null; then
        echo "❌ Error: docker not found."
        echo "   Docker is required for ssh-game to run SSH targets."
        exit 1
    fi
}

network_exists() {
    docker network ls --format '{{.Name}}' | grep -q "^${DOCKER_NETWORK}$"
}

create_network() {
    if ! network_exists; then
        docker network create --driver bridge "${DOCKER_NETWORK}" 2>/dev/null || true
    fi
}

remove_network() {
    if network_exists; then
        docker network rm "${DOCKER_NETWORK}" 2>/dev/null || true
    fi
}

container_exists() {
    docker ps -a --format '{{.Names}}' | grep -q "^${1}$"
}

container_running() {
    docker ps --format '{{.Names}}' | grep -q "^${1}$"
}

start_ssh_container() {
    local NAME="$1"
    local PORT="${2:-22}"

    if ! container_exists "$NAME"; then
        docker run -d \
            --name "$NAME" \
            --network "${DOCKER_NETWORK}" \
            -p "127.0.0.1:${PORT}:22" \
            -e ROOT_PASSWORD="cliacademy" \
            lscr.io/linuxserver/openssh-server:latest 2>/dev/null || \
        docker run -d \
            --name "$NAME" \
            --network "${DOCKER_NETWORK}" \
            -p "127.0.0.1:${PORT}:22" \
            -e PASSWORD_ACCESS=true \
            -e USER_PASSWORD="cliacademy" \
            -e USER_NAME="player" \
            docker.io/openssh/server:latest 2>/dev/null || true
    fi

    local ATTEMPTS=0
    while ! docker exec "$NAME" sh -c "echo ready" &>/dev/null 2>&1 && ((ATTEMPTS < 30)); do
        sleep 1
        ((ATTEMPTS++))
    done
}

stop_ssh_container() {
    local NAME="$1"
    if container_exists "$NAME"; then
        docker stop "$NAME" 2>/dev/null || true
        docker rm -f "$NAME" 2>/dev/null || true
    fi
}

cleanup_containers() {
    for name in $(docker ps -a --format '{{.Names}}' | grep "^${GAME_PREFIX}"); do
        docker stop "$name" 2>/dev/null || true
        docker rm -f "$name" 2>/dev/null || true
    done
}

get_container_ip() {
    local NAME="$1"
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$NAME" 2>/dev/null || echo ""
}

ssh_exec() {
    local HOST="$1"
    local CMD="$2"
    sshpass -p "cliacademy" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 "player@$HOST" "$CMD" 2>/dev/null
}

wait_for_ssh() {
    local HOST="$1"
    local PORT="${2:-22}"
    local ATTEMPTS=0
    while ! sshpass -p "cliacademy" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=2 -p "$PORT" "player@127.0.0.1" "echo ready" &>/dev/null 2>&1 && ((ATTEMPTS < 30)); do
        sleep 1
        ((ATTEMPTS++))
    done
}
