#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if grep -q 'cliacademy_l26_data' compose.yaml           && grep -q 'cliacademy_l26_net' compose.yaml           && docker_compose_service_running worker           && docker_volume_exists cliacademy_l26_data           && docker_network_exists cliacademy_l26_net; then
  exit 0
fi
echo "Expected compose-managed volume/network and running worker service."
exit 1
