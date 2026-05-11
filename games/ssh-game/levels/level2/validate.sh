#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../ssh_common.sh"
source "$SCRIPT_DIR/../../validate_ssh_state.sh"
ANSWER="${SANDBOX_DIR}/answer.txt"
if [[ -f "$ANSWER" ]] && grep -qi "ed25519" "$ANSWER"; then exit 0; fi; exit 1
