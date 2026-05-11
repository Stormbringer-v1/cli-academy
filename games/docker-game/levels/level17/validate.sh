#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_exec_test cliacademy_l17_copy 'test -f /tmp/secret.txt && grep -qx classified /tmp/secret.txt'; then
  exit 0
fi
echo "Expected /tmp/secret.txt inside cliacademy_l17_copy."
exit 1
