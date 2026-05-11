#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_container_exists cliacademy_l9_named; then
  exit 0
fi
echo "Container cliacademy_l9_named not found."
exit 1
