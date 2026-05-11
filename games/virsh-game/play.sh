#!/usr/bin/env bash
set -euo pipefail

# virsh-game: Learn KVM/libvirt management through interactive challenges
# Part of CLI Academy — https://github.com/Stormbringer-v1/cli-academy

check_virsh_prereqs() {
    if ! command -v virsh &>/dev/null; then
        echo "❌ Error: virsh is not installed."
        echo "   Install libvirt and try again."
        echo "   • Ubuntu/Debian: sudo apt install libvirt-daemon-system"
        echo "   • Fedora: sudo dnf install libvirt-daemon-system"
        echo "   • Arch: sudo pacman -S libvirt"
        exit 1
    fi

    if ! virsh list --all &>/dev/null; then
        echo "❌ Error: Cannot connect to libvirtd."
        echo "   The libvirt daemon is not running or you lack permissions."
        echo ""
        echo "   Start the daemon:"
        echo "   • sudo systemctl start libvirtd"
        echo "   • sudo systemctl enable libvirtd"
        echo ""
        echo "   Add your user to the libvirt group:"
        echo "   • sudo usermod -aG libvirt $USER"
        echo "   • Then log out and back in."
        exit 1
    fi
}

check_virsh_prereqs

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