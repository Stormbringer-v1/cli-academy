#!/usr/bin/env bash
# bash-game level 29: Signal Handling
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
trap 'echo caught; exit 0' SIGTERM
kill -s TERM $$
SOLUTION_EOF
chmod +x solution.sh
