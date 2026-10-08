#!/usr/bin/env bash
# bash-game level 14: grep Basics
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
grep '^ERROR' service.log > errors.txt
SOLUTION_EOF
chmod +x solution.sh
