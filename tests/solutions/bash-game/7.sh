#!/usr/bin/env bash
# bash-game level 7: For Loops
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
for i in 1 2 3; do
  echo "$i"
done
SOLUTION_EOF
chmod +x solution.sh
