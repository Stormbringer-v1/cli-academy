#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_image_exists alpine:3.19; then
  exit 0
fi
echo "Expected alpine:3.19 to be present locally."
exit 1
