#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if ! docker_container_exists cliacademy_l27_old           && ! docker_image_exists cliacademy_l27_tmp:latest           && ! docker_volume_exists cliacademy_l27_data           && ! docker_network_exists cliacademy_l27_net; then
  exit 0
fi
echo "Expected all cliacademy_l27_* resources to be removed."
exit 1
