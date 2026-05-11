#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_network_exists cliacademy_l21_bridge; then
  exit 0
fi
echo "Expected network cliacademy_l21_bridge."
exit 1
