#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_image_exists cliacademy_l19_ignore:latest           && [[ -f .dockerignore ]] && grep -qx 'secret.env' .dockerignore           && docker run --rm cliacademy_l19_ignore:latest sh -c 'test ! -f /app/secret.env' >/dev/null 2>&1; then
  exit 0
fi
echo "Expected .dockerignore to exclude secret.env from the image."
exit 1
