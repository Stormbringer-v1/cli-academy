#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_image_exists cliacademy_boss02_pyapp:latest           && docker_volume_exists cliacademy_boss02_data           && docker_container_running cliacademy_boss02_app           && docker_curl_contains http://127.0.0.1:8092 'python app ok'           && [[ -f answer.txt ]] && grep -qx 'python app ok' answer.txt; then
  exit 0
fi
echo "Expected running Python app, volume, and verified response."
exit 1
