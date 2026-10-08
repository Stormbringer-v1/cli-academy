#!/usr/bin/env bash

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l7_"
docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
docker run --name cliacademy_l7_logs alpine:3.19 sh -c 'echo magic-log-line' >/dev/null 2>&1 || true
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
