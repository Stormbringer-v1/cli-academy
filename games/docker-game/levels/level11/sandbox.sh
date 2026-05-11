#!/usr/bin/env bash
      set -euo pipefail

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l11_"
docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
