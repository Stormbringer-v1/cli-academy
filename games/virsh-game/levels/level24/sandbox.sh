#!/usr/bin/env bash

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh24_"

    cat > final_bad_net.xml <<'XMLEOF'
<network>
  <name>vsh24_bad_net</name>
  <forward mode='nat'/>
  <bridge name='vsh24_bad_br' stp='on' delay='0'/>
  <ip address='10.0.0.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.0.0.10' end='10.0.0.254'/>
    </dhcp>
  </ip>
</network>
XMLEOF

    cat > final_good_net.xml <<'XMLEOF'
<network>
  <name>vsh24_good_net</name>
  <forward mode='nat'/>
  <bridge name='vsh24_good_br' stp='on' delay='0'/>
  <ip address='192.168.100.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.100.10' end='192.168.100.254'/>
    </dhcp>
  </ip>
</network>
XMLEOF

    cat > final_vm.xml <<'XMLEOF'
<domain type='kvm'>
  <name>final_vm</name>
  <memory unit='MiB'>256</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
  </os>
  <devices>
    <disk type='file'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/final_vm.qcow2'/>
      <target dev='vda'/>
    </disk>
    <interface type='network'>
      <source network='vsh24_bad_net'/>
      <model type='virtio'/>
    </interface>
    <console type='pty'/>
  </devices>
</domain>
XMLEOF

    virsh net-define final_bad_net.xml >/dev/null 2>&1 || true
    virsh net-define final_good_net.xml >/dev/null 2>&1 || true
    virsh net-start vsh24_bad_net >/dev/null 2>&1 || true
    virsh net-start vsh24_good_net >/dev/null 2>&1 || true
    virsh define final_vm.xml >/dev/null 2>&1 || true
    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
    virsh_cleanup_prefix "final_vm"
}