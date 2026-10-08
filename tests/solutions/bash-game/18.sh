#!/usr/bin/env bash
# bash-game level 18: cut/paste/tr
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
cut -d, -f1 data.csv | tr '[:lower:]' '[:upper:]' > upper.txt
SOLUTION_EOF
chmod +x solution.sh
