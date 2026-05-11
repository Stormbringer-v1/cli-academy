#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if docker_container_running cliacademy_l1_web && [[ -f answer.txt ]] && grep -qx 'cliacademy_l1_web' answer.txt; then
  exit 0
fi
echo "answer.txt must contain cliacademy_l1_web."
exit 1
