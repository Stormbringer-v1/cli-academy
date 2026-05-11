#!/usr/bin/env bash
set -euo pipefail
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${GAME_DIR}/validate_solution.sh"
TEST_STDIN=''
EXPECTED_STDOUT=''
EXPECTED_EXIT=0
CHECK_STDOUT=false
CHECK_STDERR=false
REQUIRED_PATTERNS=(grep)
POST_CHECK_CMD='[[ $(grep -c '"'"'^ERROR'"'"' errors.txt 2>/dev/null || true) -eq 2 ]]'
validate_solution_level
