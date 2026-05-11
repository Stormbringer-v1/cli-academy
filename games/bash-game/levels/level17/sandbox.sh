#!/usr/bin/env bash
set -euo pipefail

setup_sandbox() {
  printf 'apple
banana
apple
apple
banana
' > words.txt
}

cleanup_sandbox() {
  :
}
