#!/usr/bin/env bash
set -euo pipefail

check_dependencies() {
    if ! command -v ssh &>/dev/null; then
        echo "❌ Error: ssh client not found."
        echo "   OpenSSH client is required."
        exit 1
    fi

    if ! command -v sshpass &>/dev/null; then
        echo "⚠️  Warning: sshpass not found."
        echo "   Some levels require sshpass for automated testing."
        echo "   Install with: apt install sshpass (Linux) or brew install sshpass (macOS)"
    fi

    if ! command -v docker &>/dev/null; then
        echo "❌ Error: docker not found."
        echo "   Docker is required to run SSH target containers."
        exit 1
    fi

    if ! docker info &>/dev/null; then
        echo "❌ Error: Docker daemon is not running."
        echo "   Please start Docker and try again."
        exit 1
    fi
}

check_dependencies

LEVEL_ORDER=(
    0 1 2 3 4 5 6 7 8 9
    boss01
    10 11 12 13 14 15 16 17
    boss02
    18 19 20 21 22
    23 24
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_PATH="$SCRIPT_DIR/../../engine/engine.sh"

if [[ ! -f "$ENGINE_PATH" ]]; then
    echo "❌ Error: Game engine not found at $ENGINE_PATH"
    exit 1
fi

source "$ENGINE_PATH"

start_game "$@"
