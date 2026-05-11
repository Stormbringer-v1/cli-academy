#!/usr/bin/env bash
set -euo pipefail

IPT_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${IPT_GAME_ROOT}/iptables_common.sh"

setup_sandbox() {
    IPT_GAME_NS="iptgame_$$"
    SANDBOX_DIR="$(mktemp -d -t "iptgame_level19.XXXXXX")"

    ip netns add "$IPT_GAME_NS" 2>/dev/null || true
    ip link add veth_host type veth peer name veth_game
    ip link set veth_game netns "$IPT_GAME_NS"
    ip addr add 10.99.0.1/24 dev veth_host 2>/dev/null || true
    ip link set veth_host up
    ip netns exec "$IPT_GAME_NS" ip addr add 10.99.0.2/24 dev veth_game
    ip netns exec "$IPT_GAME_NS" ip link set veth_game up
    ip netns exec "$IPT_GAME_NS" ip link set lo up

    run_in_netns iptables -N DOCKER-USER 2>/dev/null || true

    export IPT_GAME_NS SANDBOX_DIR
    cd "$SANDBOX_DIR"
    touch answer.txt
}

cleanup_sandbox() {
    cleanup_iptables_netns
}