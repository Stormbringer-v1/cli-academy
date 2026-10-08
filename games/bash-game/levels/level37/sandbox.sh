#!/usr/bin/env bash

setup_sandbox() {
  printf 'APP_PORT=8080
' > app.conf
}

cleanup_sandbox() {
  :
}
