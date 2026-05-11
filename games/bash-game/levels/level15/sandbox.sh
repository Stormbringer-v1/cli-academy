#!/usr/bin/env bash
set -euo pipefail

setup_sandbox() {
  printf 'foo one
foo two
' > input.txt
}

cleanup_sandbox() {
  :
}
