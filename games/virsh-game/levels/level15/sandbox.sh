#!/usr/bin/env bash

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh15_"

    cat > vsh15_net.xml <<'XMLEOF'
<network>
  <name>vsh15_net</name>
  <forward mode='nat'/>
  <bridge name='vsh15_br0' stp='on' delay='0'/>
  <ip address='192.168.150.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.150.10' end='192.168.150.254'/>
    </dhcp>
  </ip>
</network>
XMLEOF

    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}