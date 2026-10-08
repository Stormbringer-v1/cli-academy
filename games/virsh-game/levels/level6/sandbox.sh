#!/usr/bin/env bash

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh6_"
    cat > vsh6_vm.xml <<'XMLEOF'
<domain type='kvm'>
  <name>vsh6_vm</name>
  <memory unit='MiB'>512</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
  </os>
  <devices>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='serial'>
      <source path='/dev/pts/0'/>
      <target type='serial' port='0'/>
    </console>
    <disk type='file'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/vsh6_vm.qcow2'/>
      <target dev='vda'/>
    </disk>
  </devices>
</domain>
XMLEOF
    virsh define vsh6_vm.xml >/dev/null 2>&1 || true
    virsh start vsh6_vm >/dev/null 2>&1 || true
    sleep 1
    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}