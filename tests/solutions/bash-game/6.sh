#!/usr/bin/env bash
# bash-game level 6: Read Input
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
read name
echo "Hello $name"
SOLUTION_EOF
chmod +x solution.sh
