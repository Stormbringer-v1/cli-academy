#!/usr/bin/env bash

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l24"
        export COMPOSE_PROJECT_NAME="cliacademy_l24"
        docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
        cat > compose.yaml <<'EOF'
services:
  web:
    image: nginx:alpine
    ports:
      - "8094:80"
EOF
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
