#!/usr/bin/env bash

setup_sandbox() {
  printf 'INFO startup
ERROR AUTH denied
ERROR DB timeout
ERROR AUTH expired
ERROR API malformed
ERROR DB connection
ERROR AUTH blocked
' > app.log
}

cleanup_sandbox() {
  :
}
