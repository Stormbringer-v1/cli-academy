#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_container_running cliacademy_l4_nginx && docker_curl_contains http://127.0.0.1:8084 'Welcome to nginx!'; then
  exit 0
fi
echo "Expected cliacademy_l4_nginx running on localhost:8084."
exit 1
