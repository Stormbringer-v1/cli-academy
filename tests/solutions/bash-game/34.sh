#!/usr/bin/env bash
# bash-game level 34: Advanced Regex
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
grep -E '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' contacts.txt > emails.txt
SOLUTION_EOF
chmod +x solution.sh
