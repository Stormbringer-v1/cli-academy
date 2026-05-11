#!/usr/bin/env bash
set -euo pipefail

VIRSH_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${VIRSH_GAME_ROOT}/virsh_common.sh"

setup_sandbox() {
    export VIRSH_GAME_PREFIX="vsh13_"
    SANDBOX_DIR="$(mktemp -d -t "virshgame_level13.XXXXXX")"
    cd "$SANDBOX_DIR"

    mkdir -p "${SANDBOX_DIR}/pool_dir"

    cat > vsh13_pool.xml <<'XMLEOF'
<pool type='dir'>
  <name>vsh13_pool</name>
  <target>
    <path>SANDBOX_DIR_PLACEHOLDER/pool_dir</path>
  </target>
</pool>
XMLEOF

    sed -i "s|SANDBOX_DIR_PLACEHOLDER|${SANDBOX_DIR}|g" vsh13_pool.xml
    virsh pool-define vsh13_pool.xml >/dev/null 2>&1 || true
    virsh pool-start vsh13_pool >/dev/null 2>&1 || true
    virsh vol-create-as vsh13_pool mydisk.qcow2 1G --format qcow2 >/dev/null 2>&1 || true
    touch answer.txt
}

cleanup_sandbox() {
    virsh_cleanup_prefix "$VIRSH_GAME_PREFIX"
}