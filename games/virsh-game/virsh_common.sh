#!/usr/bin/env bash
set -euo pipefail

virsh_cmd() {
    virsh "$@"
}

virsh_connect() {
    local conn="${1:-qemu:///system}"
    virsh -c "$conn" "$@"
}

virsh_game_cleanup() {
    local prefix="${VIRSH_GAME_PREFIX:-game_}"
    local dom net pool vol

    for dom in $(virsh list --all --name 2>/dev/null | grep "^${prefix}" || true); do
        virsh destroy "$dom" 2>/dev/null || true
        virsh undefine "$dom" --snapshots-metadata --remove-all-storage 2>/dev/null || true
    done

    for pool in $(virsh pool-list --all --name 2>/dev/null | grep "^${prefix}" || true); do
        virsh pool-destroy "$pool" 2>/dev/null || true
        virsh pool-undefine "$pool" 2>/dev/null || true
    done

    for net in $(virsh net-list --all --name 2>/dev/null | grep "^${prefix}" || true); do
        virsh net-destroy "$net" 2>/dev/null || true
        virsh net-undefine "$net" 2>/dev/null || true
    done

    if [[ -n "${SANDBOX_DIR:-}" && -d "${SANDBOX_DIR}" ]]; then
        rm -rf "${SANDBOX_DIR}" 2>/dev/null || true
    fi
}

virsh_cleanup_prefix() {
    local prefix=$1
    local dom net pool

    for dom in $(virsh list --all --name 2>/dev/null | grep "^${prefix}" || true); do
        virsh destroy "$dom" 2>/dev/null || true
        virsh undefine "$dom" --snapshots-metadata --remove-all-storage 2>/dev/null || true
    done

    for pool in $(virsh pool-list --all --name 2>/dev/null | grep "^${prefix}" || true); do
        virsh pool-destroy "$pool" 2>/dev/null || true
        virsh pool-undefine "$pool" 2>/dev/null || true
    done

    for net in $(virsh net-list --all --name 2>/dev/null | grep "^${prefix}" || true); do
        virsh net-destroy "$net" 2>/dev/null || true
        virsh net-undefine "$net" 2>/dev/null || true
    done
}