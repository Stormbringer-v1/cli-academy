#!/usr/bin/env bash

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l12_"
        docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
        printf '#!/bin/sh
echo basic-image
' > app.sh
        chmod +x app.sh
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
