#!/usr/bin/env bash
# bash-game level 5: Test Expressions
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
if [[ -f marker.txt ]]; then
  echo "file exists"
fi
SOLUTION_EOF
chmod +x solution.sh
