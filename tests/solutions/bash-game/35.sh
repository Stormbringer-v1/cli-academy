#!/usr/bin/env bash
# bash-game level 35: find + exec
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
find logs -name '*.log' -exec grep -h 'ERROR' {} + > errors.txt
SOLUTION_EOF
chmod +x solution.sh
