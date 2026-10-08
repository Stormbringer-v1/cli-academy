#!/usr/bin/env bash

virsh_cmd() {
    virsh "$@"
}

virsh_connect() {
    local conn="${1:-qemu:///system}"
    virsh -c "$conn" "$@"
}

virsh_game_cleanup() {
    local prefix="${VIRSH_GAME_PREFIX:-game_}"
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

virsh_cleanup_prefix() {
    local prefix="${1:-}"
    local dom net pool

    if [[ -z "$prefix" ]]; then
        echo "virsh_cleanup_prefix: refusing an empty prefix" >&2
        return 1
    fi

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