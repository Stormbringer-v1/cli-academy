#!/usr/bin/env bash
# harness-fixture level exitcode: Fixture exitcode
set -euo pipefail
echo 42 > answer.txt
exit 3
