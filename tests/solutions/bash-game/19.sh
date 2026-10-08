#!/usr/bin/env bash
# bash-game level 19: xargs
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
xargs rm -f < remove-list.txt
SOLUTION_EOF
chmod +x solution.sh
