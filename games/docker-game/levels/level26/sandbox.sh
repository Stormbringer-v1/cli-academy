#!/usr/bin/env bash

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l26"
        export COMPOSE_PROJECT_NAME="cliacademy_l26"
        docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
        cat > compose.yaml <<'EOF'
services:
  worker:
    image: alpine:3.19
    command: ["sh", "-c", "sleep 600"]
EOF
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
