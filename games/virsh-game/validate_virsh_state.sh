#!/usr/bin/env bash
set -euo pipefail

virsh_domain_exists() {
    virsh dominfo "$1" &>/dev/null
}

virsh_domain_state() {
    virsh domstate "$1" 2>/dev/null || echo "not found"
}

virsh_domain_autostart() {
    local state
    state=$(virsh dominfo "$1" 2>/dev/null | grep "Autostart:" | awk '{print $2}')
    [[ "$state" == "enable" ]]
}

virsh_pool_exists() {
    virsh pool-info "$1" &>/dev/null
}

virsh_pool_state() {
    virsh pool-info "$1" 2>/dev/null | grep "State:" | awk '{print $2}' || echo "not found"
}

virsh_vol_exists() {
    virsh vol-info "$1" "$2" &>/dev/null
}

virsh_network_exists() {
    virsh net-info "$1" &>/dev/null
}

virsh_network_state() {
    local state
    state=$(virsh net-info "$1" 2>/dev/null | grep "Active:" | awk '{print $2}')
    [[ "$state" == "yes" ]]
}

virsh_snapshot_exists() {
    virsh snapshot-list "$1" 2>/dev/null | grep -q "$2"
}

virsh_dominfo_field() {
    virsh dominfo "$1" 2>/dev/null | grep "^$2:" | awk '{print $2}' || true
}

virsh_dumpxml_contains() {
    local dom=$1
    local pattern=$2
    virsh dumpxml "$dom" 2>/dev/null | grep -q "$pattern"
}

virsh_net_dumpxml_contains() {
    local net=$1
    local pattern=$2
    virsh net-dumpxml "$net" 2>/dev/null | grep -q "$pattern"
}

virsh_pool_dumpxml_contains() {
    local pool=$1
    local pattern=$2
    virsh pool-dumpxml "$pool" 2>/dev/null | grep -q "$pattern"
}