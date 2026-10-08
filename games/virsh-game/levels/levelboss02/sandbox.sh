#!/usr/bin/env bash
set -euo pipefail

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vshb2_"
    SANDBOX_DIR="$(mktemp -d -t "virshgame_boss2.XXXXXX")"
    cd "$SANDBOX_DIR"

    mkdir -p "${SANDBOX_DIR}/pool_dir"

    cat > boss2_pool.xml <<'XMLEOF'
<pool type='dir'>
  <name>boss2_pool</name>
  <target>
    <path>SANDBOX_DIR_PLACEHOLDER/pool_dir</path>
  </target>
</pool>
XMLEOF
    sed -i "s|SANDBOX_DIR_PLACEHOLDER|${SANDBOX_DIR}|g" boss2_pool.xml

    cat > boss2_net.xml <<'XMLEOF'
<network>
  <name>boss2_net</name>
  <forward mode='nat'/>
  <bridge name='boss2_br0' stp='on' delay='0'/>
  <ip address='192.168.200.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.200.10' end='192.168.200.254'/>
    </dhcp>
  </ip>
</network>
XMLEOF

    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}