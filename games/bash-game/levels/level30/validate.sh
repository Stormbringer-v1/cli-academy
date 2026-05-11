#!/usr/bin/env bash
set -euo pipefail
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${GAME_DIR}/validate_solution.sh"
TEST_STDIN=''
EXPECTED_STDOUT=Alice:prod
EXPECTED_EXIT=0
CHECK_STDOUT=true
CHECK_STDERR=false
SCRIPT_ARGS=(-n Alice -e prod)
REQUIRED_PATTERNS=(getopts)
validate_solution_level
