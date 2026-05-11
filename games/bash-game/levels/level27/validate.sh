#!/usr/bin/env bash
set -euo pipefail
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${GAME_DIR}/validate_solution.sh"
TEST_STDIN=''
EXPECTED_STDOUT=cleaned
EXPECTED_EXIT=0
CHECK_STDOUT=true
CHECK_STDERR=false
REQUIRED_PATTERNS=(trap)
POST_CHECK_CMD='[[ ! -e /tmp/bashgame_trap_file ]]'
validate_solution_level
