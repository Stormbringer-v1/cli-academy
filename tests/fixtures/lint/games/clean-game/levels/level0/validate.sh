#!/usr/bin/env bash
[[ -f ready.txt ]] && exit 0
echo "ready.txt missing"
exit 1
