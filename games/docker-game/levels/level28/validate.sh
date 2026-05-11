#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_image_exists cliacademy_l28_multi:latest           && [[ "$(grep -c '^FROM ' Dockerfile 2>/dev/null || true)" -ge 2 ]]; then
  exit 0
fi
echo "Expected at least two FROM lines and a built image."
exit 1
