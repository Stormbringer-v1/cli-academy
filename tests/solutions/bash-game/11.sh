#!/usr/bin/env bash
# bash-game level 11: Stdout Redirection
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
echo "deployment complete" > report.txt
SOLUTION_EOF
chmod +x solution.sh
