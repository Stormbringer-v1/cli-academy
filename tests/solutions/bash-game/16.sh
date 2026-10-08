#!/usr/bin/env bash
# bash-game level 16: awk Basics
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
awk -F: '{print $1}' users.txt > names.txt
SOLUTION_EOF
chmod +x solution.sh
