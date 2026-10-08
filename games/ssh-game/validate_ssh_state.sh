#!/usr/bin/env bash
set -euo pipefail

validate_ssh_state() {
    local CONTAINER="$1"
    docker exec "$CONTAINER" sh -c "$2" &>/dev/null
}

container_has_file() {
    local CONTAINER="$1"
    local FILE_PATH="$2"
    docker exec "$CONTAINER" test -f "$FILE_PATH" &>/dev/null
}

container_file_contains() {
    local CONTAINER="$1"
    local FILE_PATH="$2"
    local PATTERN="$3"
    docker exec "$CONTAINER" grep -q "$PATTERN" "$FILE_PATH" &>/dev/null
}

container_dir_exists() {
    local CONTAINER="$1"
    local DIR_PATH="$2"
    docker exec "$CONTAINER" test -d "$DIR_PATH" &>/dev/null
}
