#!/usr/bin/env bash

setup_sandbox() {
  printf 'alice:1001:/bin/bash
bob:1002:/bin/zsh
carol:1003:/bin/sh
' > users.txt
}

cleanup_sandbox() {
  :
}
