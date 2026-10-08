#!/usr/bin/env bash
# bash-game level 12: Stderr Redirection
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
# ls fails (exit 2) on purpose; keep the script's own exit status at 0
ls missing-file 2> errors.log || true
SOLUTION_EOF
chmod +x solution.sh
