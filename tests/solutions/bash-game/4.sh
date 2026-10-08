#!/usr/bin/env bash
# bash-game level 4: If/Then/Else
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
read -r n
if [[ $n -gt 0 ]]; then
  echo positive
elif [[ $n -lt 0 ]]; then
  echo negative
else
  echo zero
fi
SOLUTION_EOF
chmod +x solution.sh
