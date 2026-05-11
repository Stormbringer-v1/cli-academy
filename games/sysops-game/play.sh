#!/usr/bin/env bash
set -euo pipefail

# sysops-game: Learn Linux process management and system monitoring
# Part of CLI Academy — https://github.com/Stormbringer-v1/cli-academy

check_linux() {
    if [[ "$(uname)" != "Linux" ]]; then
        echo "⚠️  Warning: sysops-game is designed for Linux."
        echo "   Some levels use /proc, ss, lsof, strace which are Linux-only."
        echo "   Levels 0-9 (ps/kill/nice/renice) will work on macOS."
    fi
}

check_core_dependencies() {
    for cmd in ps kill; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "❌ Error: '$cmd' is not installed."
            echo "   Install procps and try again."
            exit 1
        fi
    done
}

warn_optional_dependencies() {
    local missing=""
    for cmd in ss lsof strace htop btop vmstat iostat; do
        if ! command -v "$cmd" &>/dev/null; then
            missing="$missing $cmd"
        fi
    done
    if [[ -n "$missing" ]]; then
        echo "⚠️  Warning: Some tools are not installed:$missing"
        echo "   Advanced levels may not work without them."
    fi
}

check_core_dependencies
warn_optional_dependencies
check_linux

LEVEL_ORDER=(
    0 1 2 3 4 5 6 7 8 9
    checkpoint1
    10 11 12 13 14 15 16 17 18 19
    checkpoint2
    20 21 22 23 24 25 26 27 28 29
    checkpoint3
    30 31 32 33 34
    boss_final
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_PATH="$SCRIPT_DIR/../../engine/engine.sh"

if [[ ! -f "$ENGINE_PATH" ]]; then
    echo "❌ Error: Game engine not found at $ENGINE_PATH"
    exit 1
fi

source "$ENGINE_PATH"

start_game "$@"