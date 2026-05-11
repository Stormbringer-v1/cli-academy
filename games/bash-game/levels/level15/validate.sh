#!/usr/bin/env bash
set -euo pipefail
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${GAME_DIR}/validate_solution.sh"
TEST_STDIN=''
EXPECTED_STDOUT=''
EXPECTED_EXIT=0
CHECK_STDOUT=false
CHECK_STDERR=false
REQUIRED_PATTERNS=(sed)
POST_CHECK_CMD='[[ -f output.txt ]] && ! grep -q '"'"'foo'"'"' output.txt && grep -q '"'"'bar one'"'"' output.txt'
validate_solution_level
