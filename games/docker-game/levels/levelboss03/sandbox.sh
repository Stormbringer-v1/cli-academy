#!/usr/bin/env bash

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_boss03"
export COMPOSE_PROJECT_NAME="cliacademy_boss03"
docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
