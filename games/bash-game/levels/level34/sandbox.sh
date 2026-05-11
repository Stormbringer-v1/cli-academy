#!/usr/bin/env bash
set -euo pipefail

setup_sandbox() {
  printf 'alice@example.com
invalid@@mail
bob@site.org
no-at-symbol
' > contacts.txt
}

cleanup_sandbox() {
  :
}
