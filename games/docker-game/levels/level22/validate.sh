#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_network_exists cliacademy_l22_net           && docker_container_exists cliacademy_l22_api           && [[ -f answer.txt ]] && grep -q 'Welcome to nginx!' answer.txt; then
  exit 0
fi
echo "Expected answer.txt to contain the API homepage content."
exit 1
