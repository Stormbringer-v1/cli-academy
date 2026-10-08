#!/usr/bin/env bash

setup_sandbox() {
  touch remove_me_a.tmp remove_me_b.tmp
  printf 'remove_me_a.tmp
remove_me_b.tmp
' > remove-list.txt
}

cleanup_sandbox() {
  :
}
