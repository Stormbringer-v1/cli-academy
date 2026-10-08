#!/usr/bin/env bash
# bash-game level 36: Debugging
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
PS4='+ line ${LINENO}: '
set -x
trap 'echo "about to run: $BASH_COMMAND" >&2' DEBUG
echo "debug complete"
SOLUTION_EOF
chmod +x solution.sh
