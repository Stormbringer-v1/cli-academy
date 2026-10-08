#!/usr/bin/env bash

systemctl_user() {
    systemctl --user "$@"
}

service_exists() {
    systemctl_user list-units --type=service --all 2>/dev/null | grep -q "$1"
}

service_active() {
    systemctl_user is-active "$1" 2>/dev/null
}

service_enabled() {
    systemctl_user is-enabled "$1" 2>/dev/null
}

unit_file_exists() {
    systemctl_user list-unit-files 2>/dev/null | grep -q "$1"
}

create_user_unit() {
    local NAME="$1"
    local CONTENT="$2"
    local UNIT_DIR="${HOME}/.config/systemd/user"
    mkdir -p "$UNIT_DIR"
    cat > "${UNIT_DIR}/${NAME}" <<EOF
$CONTENT
EOF
}

remove_user_unit() {
    local NAME="$1"
    local UNIT_DIR="${HOME}/.config/systemd/user"
    rm -f "${UNIT_DIR}/${NAME}" 2>/dev/null || true
}