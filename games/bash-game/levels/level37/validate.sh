#!/usr/bin/env bash
set -euo pipefail
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${GAME_DIR}/validate_solution.sh"
TEST_STDIN=''
EXPECTED_STDOUT='deploy prod ok'
EXPECTED_EXIT=0
CHECK_STDOUT=true
CHECK_STDERR=false
SCRIPT_ARGS=(-e prod -c app.conf)
REQUIRED_PATTERNS=('set[[:space:]]+-euo[[:space:]]+pipefail' getopts trap)
validate_solution_level
