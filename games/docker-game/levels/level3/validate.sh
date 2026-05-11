#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        tmp_copy="$(mktemp /tmp/dockergame_l3.XXXXXX)"
if docker_container_exists cliacademy_l3_shell && docker cp cliacademy_l3_shell:/tmp/inside.txt "$tmp_copy" >/dev/null 2>&1; then
  rm -f "$tmp_copy"
  exit 0
fi
rm -f "$tmp_copy"
echo "Expected /tmp/inside.txt inside cliacademy_l3_shell."
exit 1
