#!/usr/bin/env bash
set -euo pipefail

IPT_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${IPT_GAME_ROOT}/iptables_common.sh"

if run_in_netns iptables -C INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null; then
    exit 0
fi
exit 1