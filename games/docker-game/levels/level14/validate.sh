#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_image_exists cliacademy_l14_tools:latest           && [[ "$(grep -c '^RUN' Dockerfile 2>/dev/null || true)" -eq 1 ]]           && grep -q 'apk add --no-cache' Dockerfile           && grep -q '\' Dockerfile; then
  exit 0
fi
echo "Expected a single multi-line RUN and a built image."
exit 1
