#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if grep -q 'depends_on' compose.yaml           && grep -q 'GREETING=hello-compose' compose.yaml           && docker_compose_service_running api           && docker_compose_service_running web; then
  exit 0
fi
echo "Expected depends_on, GREETING env, and running compose services."
exit 1
