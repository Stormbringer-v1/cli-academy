#!/usr/bin/env bash
set -euo pipefail

# iptables-game: Learn Linux firewall rules through interactive challenges
# Part of CLI Academy — https://github.com/Stormbringer-v1/cli-academy

check_linux() {
    if [[ "$(uname)" != "Linux" ]]; then
        echo "❌ Error: iptables-game requires Linux."
        echo "   Network namespaces (ip netns) are only available on Linux."
        echo "   This game cannot run on macOS or WSL without a Linux VM."
        exit 1
    fi
}

check_netns_prereqs() {
    if ! command -v ip &>/dev/null; then
        echo "❌ Error: 'ip' command not found."
        echo "   Install iproute2 and try again."
        echo "   • Ubuntu/Debian: sudo apt install iproute2"
        echo "   • Fedora: sudo dnf install iproute"
        exit 1
    fi

    if ! ip netns list &>/dev/null; then
        echo "❌ Error: Cannot access network namespaces."
        echo "   You may need root privileges or CAP_NET_ADMIN."
        echo "   Try running with sudo."
        exit 1
    fi
}

check_iptables() {
    if ! command -v iptables &>/dev/null; then
        echo "❌ Error: iptables is not installed."
        echo "   • Ubuntu/Debian: sudo apt install iptables"
        echo "   • Fedora: sudo dnf install iptables"
        exit 1
    fi
}

check_linux
check_iptables
check_netns_prereqs

LEVEL_ORDER=(
    0 1 2 3 4 5 6 7 8 9
    boss01
    10 11 12 13 14 15 16 17 18 19
    boss02
    20 21 22 23 24 25 26 27
    boss03
    28 29
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_PATH="$SCRIPT_DIR/../../engine/engine.sh"

if [[ ! -f "$ENGINE_PATH" ]]; then
    echo "❌ Error: Game engine not found at $ENGINE_PATH"
    exit 1
fi

source "$ENGINE_PATH"

start_game "$@"