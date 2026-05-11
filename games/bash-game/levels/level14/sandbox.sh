#!/usr/bin/env bash
set -euo pipefail

setup_sandbox() {
  printf 'INFO ok
ERROR disk
INFO done
ERROR mem
' > service.log
}

cleanup_sandbox() {
  :
}
