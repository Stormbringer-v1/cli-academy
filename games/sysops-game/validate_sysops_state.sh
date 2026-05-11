#!/usr/bin/env bash
set -euo pipefail

sysops_answer_contains() {
    grep -q "$1" "${SANDBOX_DIR}/answer.txt" 2>/dev/null
}

sysops_answer_contains_all() {
    local content
    content=$(cat "${SANDBOX_DIR}/answer.txt" 2>/dev/null || true)
    for pattern in "$@"; do
        echo "$content" | grep -q "$pattern" || return 1
    done
}

sysops_pid_exists() {
    kill -0 "$1" 2>/dev/null
}

sysops_pid_gone() {
    ! kill -0 "$1" 2>/dev/null
}

sysops_nice_is() {
    local expected="$1"
    local actual
    actual=$(ps -o ni= -p "$2" 2>/dev/null | tr -d ' ')
    [[ "$actual" == "$expected" ]]
}

sysops_state_is() {
    local expected="$1"
    local actual
    actual=$(ps -o stat= -p "$2" 2>/dev/null | tr -d ' ')
    [[ "$actual" == "$expected" ]]
}

sysops_port_in_use() {
    ss -tlnp 2>/dev/null | grep -q ":$1 " || \
    lsof -i :"$1" 2>/dev/null | grep -q LISTEN
}

sysops_file_has_open_fds() {
    local pid="$1"
    local min_fds="${2:-1}"
    local count
    count=$(ls -1 /proc/"$pid"/fd 2>/dev/null | wc -l || echo 0)
    [[ "$count" -ge "$min_fds" ]]
}