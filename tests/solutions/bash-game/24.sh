#!/usr/bin/env bash
# bash-game level 24: Arrays
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
arr=(alpha beta gamma)
echo "${#arr[@]}"
SOLUTION_EOF
chmod +x solution.sh
