#!/usr/bin/env bash
# bash-game level 3: Exit Codes
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
false
echo $?
SOLUTION_EOF
chmod +x solution.sh
