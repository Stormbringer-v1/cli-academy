#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_image_exists cliacademy_l12_basic:latest && grep -qx 'FROM alpine:3.19' Dockerfile && grep -q 'COPY app.sh /app.sh' Dockerfile; then
  exit 0
fi
echo "Expected Dockerfile basics image and directives."
exit 1
