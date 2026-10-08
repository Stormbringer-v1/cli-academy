#!/usr/bin/env bash

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh17_"

    cat > vsh17_vm.xml <<'XMLEOF'
<domain type='kvm'>
  <name>vsh17_vm</name>
  <memory unit='MiB'>512</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
  </os>
  <devices>
    <disk type='file'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/vsh17_vm.qcow2'/>
      <target dev='vda'/>
    </disk>
    <console type='pty'/>
  </devices>
</domain>
XMLEOF

    cat > vsh17_net.xml <<'XMLEOF'
<network>
  <name>vsh17_net</name>
  <forward mode='nat'/>
  <bridge name='vsh17_br0' stp='on' delay='0'/>
  <ip address='192.168.170.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.170.10' end='192.168.170.254'/>
    </dhcp>
  </ip>
</network>
XMLEOF

    virsh define vsh17_vm.xml >/dev/null 2>&1 || true
    virsh net-define vsh17_net.xml >/dev/null 2>&1 || true
    virsh net-start vsh17_net >/dev/null 2>&1 || true
    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}