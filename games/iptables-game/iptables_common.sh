#!/usr/bin/env bash
set -euo pipefail

IPT_GAME_NS=""
IPT_GAME_PREFIX="iptg_"

cleanup_netns() {
    if [[ -n "$IPT_GAME_NS" ]] && ip netns list &>/dev/null; then
        ip netns delete "$IPT_GAME_NS" 2>/dev/null || true
    fi
    if [[ -n "${VETH_HOST:-}" ]]; then
        ip link delete "$VETH_HOST" 2>/dev/null || true
    fi
}

setup_netns_sandbox() {
    IPT_GAME_NS="iptgame_$$"
    SANDBOX_DIR="$(mktemp -d -t "iptgame_level${LEVEL:-0}.XXXXXX")"

    ip netns add "$IPT_GAME_NS" 2>/dev/null || true

    ip link add veth_host type veth peer name veth_game
    ip link set veth_game netns "$IPT_GAME_NS"

    ip addr add 10.99.0.1/24 dev veth_host 2>/dev/null || true
    ip link set veth_host up

    ip netns exec "$IPT_GAME_NS" ip addr add 10.99.0.2/24 dev veth_game
    ip netns exec "$IPT_GAME_NS" ip link set veth_game up
    ip netns exec "$IPT_GAME_NS" ip link set lo up

    export IPT_GAME_NS
    export SANDBOX_DIR
    export NETNS_EXEC="ip netns exec $IPT_GAME_NS"

    cd "$SANDBOX_DIR"
}

run_in_netns() {
    ip netns exec "$IPT_GAME_NS" "$@"
}

cleanup_iptables_netns() {
    if [[ -n "$IPT_GAME_NS" ]] && ip netns list &>/dev/null 2>&1; then
        ip netns delete "$IPT_GAME_NS" 2>/dev/null || true
    fi
    if [[ -n "${VETH_HOST:-}" ]]; then
        ip link delete "$VETH_HOST" 2>/dev/null || true
    fi
    if [[ -n "${SANDBOX_DIR:-}" && -d "$SANDBOX_DIR" ]]; then
        rm -rf "$SANDBOX_DIR" 2>/dev/null || true
    fi
}

nft_cmd() {
    if command -v nft &>/dev/null; then
        nft "$@"
    else
        echo "nft command not available" >&2
        return 1
    fi
}

run_nft_in_netns() {
    ip netns exec "$IPT_GAME_NS" nft "$@"
}