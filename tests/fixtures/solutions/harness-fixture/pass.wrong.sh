#!/usr/bin/env bash
# harness-fixture level pass: Fixture pass (WRONG)
# Mistake: writes 41 instead of 42, so the validator check "answer.txt contains 42" must reject it.
set -euo pipefail
echo 41 > answer.txt
