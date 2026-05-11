#!/usr/bin/env bash
set -euo pipefail

setup_sandbox() {
  printf 'alice,dev
bob,ops
' > data.csv
}

cleanup_sandbox() {
  :
}
