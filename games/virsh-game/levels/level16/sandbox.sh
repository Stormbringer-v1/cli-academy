#!/usr/bin/env bash

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh16_"

    cat > vsh16_net.xml <<'XMLEOF'
<network>
  <name>vsh16_net</name>
  <forward mode='nat'/>
  <bridge name='vsh16_br0' stp='on' delay='0'/>
  <ip address='192.168.160.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.160.10' end='192.168.160.254'/>
    </dhcp>
  </ip>
</network>
XMLEOF

    virsh net-define vsh16_net.xml >/dev/null 2>&1 || true
    virsh net-start vsh16_net >/dev/null 2>&1 || true
    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}