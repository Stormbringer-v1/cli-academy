#!/usr/bin/env bash
set -euo pipefail

docker_compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    return 1
  fi
}

docker_container_exists() {
  docker inspect "$1" >/dev/null 2>&1
}

docker_container_running() {
  [[ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null || true)" == "true" ]]
}

docker_image_exists() {
  docker image inspect "$1" >/dev/null 2>&1
}

docker_volume_exists() {
  docker volume inspect "$1" >/dev/null 2>&1
}

docker_network_exists() {
  docker network inspect "$1" >/dev/null 2>&1
}

docker_exec_test() {
  docker exec "$1" sh -lc "$2" >/dev/null 2>&1
}

docker_logs_contain() {
  docker logs "$1" 2>&1 | grep -Fq "$2"
}

docker_curl_contains() {
  curl -fsS "$1" 2>/dev/null | grep -Fq "$2"
}

docker_inspect_value() {
  docker inspect -f "$2" "$1" 2>/dev/null || true
}

docker_compose_service_running() {
  docker_compose_cmd ps "$1" 2>/dev/null | grep -Eq 'Up|running|healthy'
}

docker_network_has_container() {
  docker network inspect "$1" 2>/dev/null | grep -Fq "$2"
}

docker_container_file_equals() {
  local container=$1
  local path=$2
  local expected=$3
  [[ "$(docker exec "$container" sh -lc "cat $path" 2>/dev/null || true)" == "$expected" ]]
}
