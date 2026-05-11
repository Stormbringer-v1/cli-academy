#!/usr/bin/env bash
      set -euo pipefail

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l27_"
docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
docker create --name cliacademy_l27_old alpine:3.19 true >/dev/null
docker volume create cliacademy_l27_data >/dev/null
docker network create cliacademy_l27_net >/dev/null
docker image pull alpine:3.19 >/dev/null
docker tag alpine:3.19 cliacademy_l27_tmp:latest
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
