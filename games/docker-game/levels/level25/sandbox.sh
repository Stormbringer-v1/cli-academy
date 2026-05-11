#!/usr/bin/env bash
      set -euo pipefail

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l25"
        export COMPOSE_PROJECT_NAME="cliacademy_l25"
        docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
        cat > compose.yaml <<'EOF'
services:
  api:
    image: alpine:3.19
    command: ["sh", "-c", "while true; do echo ${GREETING:-missing} > /tmp/greeting; sleep 5; done"]
  web:
    image: alpine:3.19
    command: ["sh", "-c", "sleep 600"]
EOF
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
