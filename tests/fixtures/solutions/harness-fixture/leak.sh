#!/usr/bin/env bash
# harness-fixture level leak: Fixture leak
set -euo pipefail
echo 42 > answer.txt
: > "${TMPDIR:?}/harness-fixture-leak"
