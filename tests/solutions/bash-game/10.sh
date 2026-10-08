#!/usr/bin/env bash
# bash-game level 10: Pipes
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
grep -i error app.log | wc -l | tr -d ' '
SOLUTION_EOF
chmod +x solution.sh
