#!/usr/bin/env bash

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh18_"

    cat > vsh18_vm.xml <<'XMLEOF'
<domain type='kvm'>
  <name>vsh18_vm</name>
  <memory unit='MiB'>512</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
  </os>
  <devices>
    <disk type='file'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/vsh18_vm.qcow2'/>
      <target dev='vda'/>
    </disk>
    <console type='pty'/>
  </devices>
</domain>
XMLEOF

    virsh define vsh18_vm.xml >/dev/null 2>&1 || true
    virsh start vsh18_vm >/dev/null 2>&1 || true
    sleep 1
    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}