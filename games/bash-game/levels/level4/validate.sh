#!/usr/bin/env bash
set -euo pipefail
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${GAME_DIR}/validate_solution.sh"
TEST_STDIN='5
'
EXPECTED_STDOUT=positive
EXPECTED_EXIT=0
CHECK_STDOUT=true
CHECK_STDERR=false
REQUIRED_PATTERNS=('if[[:space:]]+\[\[')
validate_solution_level
