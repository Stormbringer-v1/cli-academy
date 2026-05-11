#!/usr/bin/env bash
set -euo pipefail

ipt_chain_exists() {
    local chain="${1:-INPUT}"
    ip netns exec "$IPT_GAME_NS" iptables -L "$chain" -n &>/dev/null
}

ipt_rule_count() {
    local chain="${1:-INPUT}"
    ip netns exec "$IPT_GAME_NS" iptables -L "$chain" -n | tail -n +3 | grep -c -v "^$" || echo 0
}

ipt_has_rule() {
    local chain="${1:-INPUT}"
    local spec="${2:-}"
    ip netns exec "$IPT_GAME_NS" iptables -C "$chain" $spec 2>/dev/null
}

ipt_default_policy() {
    local chain="${1:-INPUT}"
    ip netns exec "$IPT_GAME_NS" iptables -L "$chain" | grep "^Chain" | awk '{print $4}' | tr -d ')' || echo "unknown"
}

ipt_pingable() {
    local host="${1:-10.99.0.1}"
    ip netns exec "$IPT_GAME_NS" ping -c1 -W1 "$host" &>/dev/null
}

ipt_port_open() {
    local host="${1:-10.99.0.1}"
    local port="${2:-80}"
    ip netns exec "$IPT_GAME_NS" nc -z -w1 "$host" "$port" 2>/dev/null
}

nft_table_exists() {
    local table="${1:-filter}"
    ip netns exec "$IPT_GAME_NS" nft list tables 2>/dev/null | grep -q "table $table" || true
}

nft_chain_exists() {
    local table="${1:-filter}"
    local chain="${2:-input}"
    ip netns exec "$IPT_GAME_NS" nft list chain "$table" "$chain" 2>/dev/null | grep -q "chain $chain" || true
}

nft_has_rule() {
    local table="${1:-filter}"
    local chain="${2:-input}"
    local rule="${3:-}"
    ip netns exec "$IPT_GAME_NS" nft list chain "$table" "$chain" 2>/dev/null | grep -q "$rule" || true
}