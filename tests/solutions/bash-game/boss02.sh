#!/usr/bin/env bash
# bash-game level boss02: BOSS 02 - Log Pipeline
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
grep '^ERROR' app.log \
  | awk '{print $2}' \
  | sort \
  | uniq -c \
  | sort -rn \
  | awk '{print $1, $2}' > report.txt
SOLUTION_EOF
chmod +x solution.sh
