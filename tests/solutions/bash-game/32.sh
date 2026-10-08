#!/usr/bin/env bash
# bash-game level 32: Here Strings
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
wc -w <<< "lorem ipsum" | tr -d ' '
SOLUTION_EOF
chmod +x solution.sh
