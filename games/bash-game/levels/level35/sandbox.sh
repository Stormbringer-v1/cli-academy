#!/usr/bin/env bash

setup_sandbox() {
  mkdir -p logs
  printf 'INFO ok
ERROR one
' > logs/a.log
  printf 'ERROR two
INFO done
' > logs/b.log
}

cleanup_sandbox() {
  :
}
