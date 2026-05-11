#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_image_exists cliacademy_l18_snapshot:latest           && docker run --rm cliacademy_l18_snapshot:latest sh -c 'grep -qx snapshot /tmp/note.txt' >/dev/null 2>&1; then
  exit 0
fi
echo "Expected committed image with /tmp/note.txt."
exit 1
