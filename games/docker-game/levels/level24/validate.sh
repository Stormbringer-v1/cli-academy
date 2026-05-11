#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_compose_service_running web && docker_curl_contains http://127.0.0.1:8094 'Welcome to nginx!'; then
  exit 0
fi
echo "Expected compose web service to be running."
exit 1
