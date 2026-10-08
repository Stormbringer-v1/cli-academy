#!/usr/bin/env bash

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh12_"

    mkdir -p "${SANDBOX_DIR}/pool_dir"

    cat > vsh12_pool.xml <<'XMLEOF'
<pool type='dir'>
  <name>vsh12_pool</name>
  <target>
    <path>SANDBOX_DIR_PLACEHOLDER/pool_dir</path>
  </target>
</pool>
XMLEOF

    sed -i "s|SANDBOX_DIR_PLACEHOLDER|${SANDBOX_DIR}|g" vsh12_pool.xml
    virsh pool-define vsh12_pool.xml >/dev/null 2>&1 || true
    virsh pool-start vsh12_pool >/dev/null 2>&1 || true
    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}