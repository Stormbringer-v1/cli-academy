#!/usr/bin/env bash
set -euo pipefail

setup_sandbox() {
  printf 'ready
' > marker.txt
}

cleanup_sandbox() {
  :
}
