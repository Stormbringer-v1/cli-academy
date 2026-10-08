#!/usr/bin/env bash
set -euo pipefail
# Observe the submodule registration; never add it.
path=$(git config -f .gitmodules --get submodule.lib.path 2>/dev/null || true)
url=$(git config -f .gitmodules --get submodule.lib.url 2>/dev/null || true)
if [[ "$path" != "lib" || "$url" != *submod ]]; then
  echo "No submodule 'lib' pointing at submod in .gitmodules."
  exit 1
fi
if ! git ls-files -s lib | grep -q '^160000 '; then
  echo "lib is not registered as a submodule in the index."
  exit 1
fi
if [[ ! -f lib/file.txt ]]; then
  echo "lib/ has not been populated."
  exit 1
fi
exit 0
