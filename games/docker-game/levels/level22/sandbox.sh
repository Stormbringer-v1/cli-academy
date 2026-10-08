#!/usr/bin/env bash

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l22_"
docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
docker network create cliacademy_l22_net >/dev/null
docker run -d --name cliacademy_l22_api --network cliacademy_l22_net nginx:alpine >/dev/null
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
