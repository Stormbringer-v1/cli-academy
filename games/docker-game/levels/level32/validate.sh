#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_compose_service_running web           && docker_compose_service_running api           && docker_compose_service_running db           && docker_compose_service_running cache; then
  exit 0
fi
echo "Expected web/api/db/cache services running via compose."
exit 1
