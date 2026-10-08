#!/usr/bin/env bash

setup_sandbox() {
  printf 'c
a
b
' > a.txt
  printf 'b
c
a
' > b.txt
}

cleanup_sandbox() {
  :
}
