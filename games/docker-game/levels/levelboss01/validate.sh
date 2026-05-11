#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_container_running cliacademy_boss01_web           && docker_container_file_equals cliacademy_boss01_web /usr/share/nginx/html/index.html 'academy boss'           && docker_curl_contains http://127.0.0.1:8091 'academy boss'           && [[ -f answer.txt ]] && grep -qx 'academy boss' answer.txt           && ! docker_container_exists cliacademy_boss01_old; then
  exit 0
fi
echo "Expected running nginx with custom page, answer.txt, and old container removed."
exit 1
