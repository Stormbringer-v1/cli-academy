#!/usr/bin/env bash
if [[ -f answer.txt ]] && grep -qx '42' answer.txt; then
  exit 0
fi
echo "answer.txt must contain 42"
exit 1
