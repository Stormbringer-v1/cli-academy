#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if ! docker_container_exists cliacademy_l6_old; then
  exit 0
fi
echo "cliacademy_l6_old should be removed."
exit 1
