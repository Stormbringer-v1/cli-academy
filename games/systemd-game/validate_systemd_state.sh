#!/usr/bin/env bash
set -euo pipefail

systemd_answer_contains() {
    grep -q "$1" "${SANDBOX_DIR}/answer.txt" 2>/dev/null
}

systemd_unit_active() {
    systemctl --user is-active "$1" 2>/dev/null
}

systemd_unit_enabled() {
    systemctl --user is-enabled "$1" 2>/dev/null
}

systemd_unit_exists() {
    systemctl --user list-units --type=service --all 2>/dev/null | grep -q "$1"
}

journal_has_pattern() {
    journalctl --user -u "$1" 2>/dev/null | grep -q "$2"
}