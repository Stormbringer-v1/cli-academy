#!/usr/bin/env bash
        set -euo pipefail

        DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${DOCKER_GAME_ROOT}/validate_docker_state.sh"

        if [[ -f answer.txt ]] && grep -qx 'magic-log-line' answer.txt; then
  exit 0
fi
echo "answer.txt must contain magic-log-line."
exit 1
