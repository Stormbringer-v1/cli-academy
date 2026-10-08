#!/usr/bin/env bash

        docker_compose_cmd() {
          if docker compose version >/dev/null 2>&1; then
            docker compose "$@"
          elif command -v docker-compose >/dev/null 2>&1; then
            docker-compose "$@"
          else
            echo "docker compose is not available." >&2
            return 1
          fi
        }

        docker_cleanup_prefix() {
          local prefix="${1:-}"
          local name ref

          if [[ -z "$prefix" ]]; then
            echo "docker_cleanup_prefix: refusing an empty prefix" >&2
            return 1
          fi

          while IFS= read -r name; do
            [[ -n "$name" && "$name" == ${prefix}* ]] || continue
            docker rm -f "$name" >/dev/null 2>&1 || true
          done <<EOF
$(docker ps -a --format '{{.Names}}' 2>/dev/null || true)
EOF

          while IFS= read -r ref; do
            [[ -n "$ref" && "$ref" == ${prefix}* ]] || continue
            docker rmi -f "$ref" >/dev/null 2>&1 || true
          done <<EOF
$(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null || true)
EOF

          while IFS= read -r name; do
            [[ -n "$name" && "$name" == ${prefix}* ]] || continue
            docker volume rm "$name" >/dev/null 2>&1 || true
          done <<EOF
$(docker volume ls --format '{{.Name}}' 2>/dev/null || true)
EOF

          while IFS= read -r name; do
            [[ -n "$name" && "$name" == ${prefix}* ]] || continue
            docker network rm "$name" >/dev/null 2>&1 || true
          done <<EOF
$(docker network ls --format '{{.Name}}' 2>/dev/null || true)
EOF
        }

        docker_game_cleanup() {
          if [[ -n "${COMPOSE_PROJECT_NAME:-}" ]]; then
            docker_compose_cmd down -v --remove-orphans >/dev/null 2>&1 || true
          fi
          if [[ -n "${DOCKER_GAME_PREFIX:-}" ]]; then
            docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
          fi
        }
