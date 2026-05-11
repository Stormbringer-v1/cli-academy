#!/usr/bin/env bash
set -euo pipefail

setup_sandbox() {
  mkdir -p three-files && touch three-files/a three-files/b three-files/c
}

cleanup_sandbox() {
  :
}
