#!/usr/bin/env bash
      set -euo pipefail

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l13_"
        docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
        printf 'build-success
' > message.txt
        cat > Dockerfile <<'EOF'
FROM alpine:3.19
COPY message.txt /message.txt
CMD ["sh", "-c", "cat /message.txt"]
EOF
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
