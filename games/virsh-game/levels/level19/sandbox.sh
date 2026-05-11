#!/usr/bin/env bash
set -euo pipefail

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh19_"
    SANDBOX_DIR="$(mktemp -d -t "virshgame_level19.XXXXXX")"
    cd "$SANDBOX_DIR"

    cat > vsh19_vm.xml <<'XMLEOF'
<domain type='kvm'>
  <name>vsh19_vm</name>
  <memory unit='MiB'>512</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
  </os>
  <devices>
    <disk type='file'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/vsh19_vm.qcow2'/>
      <target dev='vda'/>
    </disk>
    <console type='pty'/>
  </devices>
</domain>
XMLEOF

    virsh define vsh19_vm.xml >/dev/null 2>&1 || true
    virsh snapshot-create-as vsh19_vm init_snap >/dev/null 2>&1 || true
    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}