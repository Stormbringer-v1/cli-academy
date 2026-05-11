#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        mem="$(docker_inspect_value cliacademy_l30_limits '{{.HostConfig.Memory}}')"
cpus="$(docker_inspect_value cliacademy_l30_limits '{{.HostConfig.NanoCpus}}')"
if docker_container_exists cliacademy_l30_limits && [[ "${mem:-0}" -gt 0 ]] && [[ "${cpus:-0}" -gt 0 ]]; then
  exit 0
fi
echo "Expected non-zero memory and CPU limits on cliacademy_l30_limits."
exit 1
