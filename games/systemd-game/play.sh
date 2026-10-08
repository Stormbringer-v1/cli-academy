#!/usr/bin/env bash
set -uo pipefail

# systemd-game: Learn systemd service management
# Part of CLI Academy — https://github.com/Stormbringer-v1/cli-academy

check_linux() {
    if [[ "$(uname)" != "Linux" ]]; then
        echo "❌ Error: systemd-game requires Linux."
        echo "   systemd is only available on Linux systems."
        echo "   This game cannot run on macOS or WSL without a Linux VM."
        exit 2
    fi
}

check_systemd() {
    if ! command -v systemctl &>/dev/null; then
        echo "❌ Error: systemctl not found."
        echo "   systemd is required but not installed."
        exit 2
    fi

    if ! systemctl --version &>/dev/null; then
        echo "❌ Error: Cannot run systemctl."
        echo "   You may need root privileges or systemd may not be running."
        exit 2
    fi
}

check_user_slice() {
    if ! systemctl --user status &>/dev/null 2>&1; then
        echo "⚠️  Warning: systemctl --user is not available."
        echo "   Some beginner levels require a user systemd instance."
        echo "   Try running: export XDG_RUNTIME_DIR=/run/user/$(id -u)"
        echo "   Or run as root for full functionality."
    fi
}

check_linux
check_systemd
check_user_slice

# shellcheck disable=SC2034  # LEVEL_ORDER is read by engine/engine.sh
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
    exit 2
fi

# shellcheck source=../../engine/engine.sh
source "$ENGINE_PATH"

start_game "$@"