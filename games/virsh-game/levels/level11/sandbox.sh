#!/usr/bin/env bash

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh11_"

    mkdir -p "${SANDBOX_DIR}/pool_dir"

    cat > vsh11_pool.xml <<'XMLEOF'
<pool type='dir'>
  <name>vsh11_pool</name>
  <target>
    <path>SANDBOX_DIR_PLACEHOLDER/pool_dir</path>
  </target>
</pool>
XMLEOF

    sed -i "s|SANDBOX_DIR_PLACEHOLDER|${SANDBOX_DIR}|g" vsh11_pool.xml
    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}