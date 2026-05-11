#!/usr/bin/env bash
      set -euo pipefail

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l2_"
docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
docker create --name cliacademy_l2_stopped hello-world >/dev/null
docker run -d --name cliacademy_l2_running nginx:alpine >/dev/null
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
