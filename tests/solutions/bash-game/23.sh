#!/usr/bin/env bash
# bash-game level 23: Arithmetic
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
read -r a b
echo $((a + b))
SOLUTION_EOF
chmod +x solution.sh
