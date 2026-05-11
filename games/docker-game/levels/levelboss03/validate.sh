#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_compose_service_running frontend           && docker_compose_service_running api           && docker_compose_service_running db           && docker_network_exists cliacademy_boss03_net; then
  exit 0
fi
echo "Expected running frontend/api/db services on custom network."
exit 1
