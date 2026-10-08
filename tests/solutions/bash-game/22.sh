#!/usr/bin/env bash
# bash-game level 22: Command Substitution
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
count=$(ls three-files | wc -l)
echo "${count// /}"
SOLUTION_EOF
chmod +x solution.sh
