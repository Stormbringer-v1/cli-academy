#!/usr/bin/env bash
# bash-game level 26: Process Substitution
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
if diff <(sort a.txt) <(sort b.txt) > /dev/null; then
  echo same
fi
SOLUTION_EOF
chmod +x solution.sh
