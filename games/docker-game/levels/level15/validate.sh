#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_volume_exists cliacademy_l15_data           && docker run --rm -v cliacademy_l15_data:/data alpine:3.19 sh -c 'grep -qx saved /data/status.txt' >/dev/null 2>&1; then
  exit 0
fi
echo "Expected saved data inside cliacademy_l15_data."
exit 1
