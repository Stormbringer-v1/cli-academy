#!/usr/bin/env bash
set -euo pipefail
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${GAME_DIR}/validate_solution.sh"
TEST_STDIN=''
EXPECTED_STDOUT=''
EXPECTED_EXIT=0
CHECK_STDOUT=false
CHECK_STDERR=false
REQUIRED_PATTERNS=('>[[:space:]]*report\.txt')
POST_CHECK_CMD='[[ -f report.txt ]] && grep -qx '"'"'deployment complete'"'"' report.txt'
validate_solution_level
