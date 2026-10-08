#!/usr/bin/env bash

setup_sandbox() {
  printf 'alice,dev
bob,ops
' > data.csv
}

cleanup_sandbox() {
  :
}
