#!/usr/bin/env bash
      set -euo pipefail

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l17_"
        docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
        printf 'classified
' > secret.txt
        docker run -d --name cliacademy_l17_copy alpine:3.19 sh -c 'sleep 600' >/dev/null
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
