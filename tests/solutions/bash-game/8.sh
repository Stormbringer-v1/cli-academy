#!/usr/bin/env bash
# bash-game level 8: While Loops
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
count=0
while read -r line; do
  count=$((count + 1))
done < lines.txt
echo "$count"
SOLUTION_EOF
chmod +x solution.sh
