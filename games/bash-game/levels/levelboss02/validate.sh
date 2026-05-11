#!/usr/bin/env bash
set -euo pipefail
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${GAME_DIR}/validate_solution.sh"
TEST_STDIN=''
EXPECTED_STDOUT=''
EXPECTED_EXIT=0
CHECK_STDOUT=false
CHECK_STDERR=false
REQUIRED_PATTERNS=('\|' sort uniq)
POST_CHECK_CMD='[[ -f report.txt ]] && diff -u <(printf '"'"'3 AUTH
2 DB
1 API
'"'"') report.txt >/dev/null'
validate_solution_level
