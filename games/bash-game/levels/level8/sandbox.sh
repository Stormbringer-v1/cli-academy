#!/usr/bin/env bash
set -euo pipefail

setup_sandbox() {
  printf 'a
b
c
' > lines.txt
}

cleanup_sandbox() {
  :
}
