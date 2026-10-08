#!/usr/bin/env bash
set -euo pipefail
# Observe the recovery. The setup hard-reset "Second commit" away, so the reflog already
# holds a "reset:" entry; only the branch itself can show that the commit is back.
subject="$(git log -1 --format=%s 2>/dev/null || true)"
if [[ "$subject" == "Second commit" ]] && grep -q "second" file.txt 2>/dev/null; then
  exit 0
fi
echo "Commit recovery not verified."
exit 1
