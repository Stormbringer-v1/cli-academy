#!/usr/bin/env bash
# bash-game level 25: Associative Arrays
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
declare -A ports
ports[prod]=8080
echo "${ports[prod]}"
SOLUTION_EOF
chmod +x solution.sh
