#!/usr/bin/env bash

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l19_"
        docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
        printf 'hello
' > app.txt
        printf 'TOP_SECRET=1
' > secret.env
        cat > Dockerfile <<'EOF'
FROM alpine:3.19
WORKDIR /app
COPY . /app
CMD ["sh", "-c", "ls -1 /app"]
EOF
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
