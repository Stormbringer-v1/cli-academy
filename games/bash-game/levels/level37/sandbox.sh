#!/usr/bin/env bash
set -euo pipefail

setup_sandbox() {
  printf 'APP_PORT=8080
' > app.conf
}

cleanup_sandbox() {
  :
}
