#!/usr/bin/env bash
set -euo pipefail
if [[ -d "lib" ]] && [[ -f ".gitmodules" ]]; then
  if grep -q "submod" .gitmodules 2>/dev/null; then
    exit 0
  fi
fi
echo "Submodule not properly configured."
exit 1