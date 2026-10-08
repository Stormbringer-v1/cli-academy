#!/usr/bin/env bash
# bash-game level 1: Variables
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
NAME=world
echo "Hello $NAME"
SOLUTION_EOF
chmod +x solution.sh
