#!/usr/bin/env bash
      set -euo pipefail

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_l32"
        export COMPOSE_PROJECT_NAME="cliacademy_l32"
        docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
        cat > app.sh <<'EOF'
#!/bin/sh
while true; do printf 'api ok
' | nc -l -p 8080; done
EOF
        chmod +x app.sh
        cat > Dockerfile <<'EOF'
FROM alpine:3.19
RUN apk add --no-cache netcat-openbsd
COPY app.sh /app.sh
CMD ["sh", "/app.sh"]
EOF
        cat > compose.yaml <<'EOF'
services:
  web:
    image: nginx:alpine
  api:
    build: .
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: example
  cache:
    image: redis:7-alpine
EOF
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
