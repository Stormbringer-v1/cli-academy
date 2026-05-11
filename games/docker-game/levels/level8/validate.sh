#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        expected_ip="$(docker_inspect_value cliacademy_l8_app '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')"
if [[ -n "$expected_ip" && -f answer.txt ]] && grep -qx "$expected_ip" answer.txt; then
  exit 0
fi
echo "answer.txt must contain the inspected IP address."
exit 1
