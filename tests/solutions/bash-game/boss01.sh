#!/usr/bin/env bash
# bash-game level boss01: BOSS 01 - Shell Basics
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
for ((i = n; i >= 1; i--)); do
  echo "$i"
done
SOLUTION_EOF
chmod +x solution.sh
