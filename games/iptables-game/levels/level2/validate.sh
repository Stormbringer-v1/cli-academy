#!/usr/bin/env bash
set -euo pipefail

IPT_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${IPT_GAME_ROOT}/iptables_common.sh"
source "${IPT_GAME_ROOT}/validate_iptables_state.sh"

if run_in_netns iptables -C INPUT -p icmp -j DROP 2>/dev/null; then
    exit 0
fi
exit 1