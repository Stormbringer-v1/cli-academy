#!/usr/bin/env bash

setup_sandbox() {
  printf 'INFO start
ERROR disk
warn cache
error timeout
' > app.log
}

cleanup_sandbox() {
  :
}
