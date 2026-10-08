#!/usr/bin/env bash

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_boss01_"
docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
docker create --name cliacademy_boss01_old alpine:3.19 true >/dev/null
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
