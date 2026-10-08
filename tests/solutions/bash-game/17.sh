#!/usr/bin/env bash
# bash-game level 17: sort and uniq
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
sort words.txt | uniq -c | sort -rn > freq.txt
SOLUTION_EOF
chmod +x solution.sh
