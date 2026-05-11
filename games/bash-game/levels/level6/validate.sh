#!/usr/bin/env bash
set -euo pipefail
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${GAME_DIR}/validate_solution.sh"
TEST_STDIN='Robert
'
EXPECTED_STDOUT='Hello Robert'
EXPECTED_EXIT=0
CHECK_STDOUT=true
CHECK_STDERR=false
REQUIRED_PATTERNS=('read[[:space:]]+[A-Za-z_][A-Za-z0-9_]*')
validate_solution_level
