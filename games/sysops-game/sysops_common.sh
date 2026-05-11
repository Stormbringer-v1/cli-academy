#!/usr/bin/env bash
set -euo pipefail

SYS_GAME_PIDS=()
SYS_GAME_PORTS=()
SYS_GAME_LOCKS=()

cleanup_sysops() {
    for pid in ${SYS_GAME_PIDS[@]:-}; do
        kill "$pid" 2>/dev/null || true
    done
    sleep 0.5
    for pid in ${SYS_GAME_PIDS[@]:-}; do
        kill -9 "$pid" 2>/dev/null || true
    done

    for lockfile in ${SYS_GAME_LOCKS[@]:-}; do
        rm -f "$lockfile" 2>/dev/null || true
    done

    for port in ${SYS_GAME_PORTS[@]:-}; do
        fuser -k "${port}/tcp" 2>/dev/null || true
    done

    if [[ -n "${SANDBOX_DIR:-}" && -d "$SANDBOX_DIR" ]]; then
        rm -rf "$SANDBOX_DIR" 2>/dev/null || true
    fi
}

spawn_rogue() {
    local NAME="$1"
    local TYPE="${2:-idle}"
    local SANDBOX="${SANDBOX_DIR:-.}"

    case "$TYPE" in
        idle)
            sleep 99999 &
            ;;
        cpu)
            bash -c 'while true; do :; done' &
            ;;
        trap)
            bash -c 'trap "" TERM; while true; do sleep 1; done' &
            ;;
        zombie)
            bash -c '(exit 0) & wait' &
            ;;
        leak)
            local N="${3:-100}"
            bash -c "for i in \$(seq 1 $N); do exec {fd}>/dev/null; sleep 0.1; done; sleep 99999" &
            ;;
        stopped)
            sleep 99999 &
            local PID=$!
            kill -STOP "$PID"
            SYS_GAME_PIDS+=($PID)
            echo "$PID" > "${SANDBOX}/.${NAME}.pid"
            return
            ;;
    esac
    SYS_GAME_PIDS+=($!)
    echo "$!" > "${SANDBOX}/.${NAME}.pid"
}

spawn_listener() {
    local NAME="$1"
    local PORT="$2"
    local SANDBOX="${SANDBOX_DIR:-.}"

    python3 -c "
import socket, time
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('127.0.0.1', $PORT))
s.listen(1)
while True: time.sleep(1)
" &
    SYS_GAME_PIDS+=($!)
    SYS_GAME_PORTS+=("$PORT")
    echo "$!" > "${SANDBOX}/.${NAME}.pid"
}

grab_lock() {
    local NAME="$1"
    local LOCKFILE="${SANDBOX_DIR:-.}/${2:-critical.lock}"
    touch "$LOCKFILE"
    flock "$LOCKFILE" sleep 99999 &
    SYS_GAME_PIDS+=($!)
    SYS_GAME_LOCKS+=("$LOCKFILE")
    echo "$!" > "${SANDBOX_DIR:-.}/.${NAME}.pid"
}

pid_alive() {
    kill -0 "$1" 2>/dev/null
}

pid_dead() {
    ! kill -0 "$1" 2>/dev/null
}

get_pid_nice() {
    ps -o ni= -p "$1" 2>/dev/null | tr -d ' ' || echo ""
}

get_pid_state() {
    ps -o stat= -p "$1" 2>/dev/null | tr -d ' ' || echo ""
}