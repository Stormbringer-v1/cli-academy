#!/usr/bin/env bash
# bash-game level 0: Echo and Exit
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
echo hello
exit 0
SOLUTION_EOF
chmod +x solution.sh
