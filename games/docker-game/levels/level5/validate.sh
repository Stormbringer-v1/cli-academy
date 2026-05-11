#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_container_running cliacademy_l5_exec && docker_exec_test cliacademy_l5_exec 'test -f /tmp/marker.txt'; then
  exit 0
fi
echo "Expected /tmp/marker.txt inside cliacademy_l5_exec."
exit 1
