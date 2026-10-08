#!/usr/bin/env bash
LEVEL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${LEVEL_ROOT}/clean_common.sh"
setup_sandbox() { clean_setup; }
cleanup_sandbox() { :; }
