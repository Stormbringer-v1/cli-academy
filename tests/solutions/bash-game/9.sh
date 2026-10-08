#!/usr/bin/env bash
# bash-game level 9: Case Statements
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
read -r input
case "$input" in
  start) echo running ;;
  stop) echo stopped ;;
  *) echo unknown ;;
esac
SOLUTION_EOF
chmod +x solution.sh
