#!/usr/bin/env bash
# bash-game level 15: sed Basics
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
sed 's/foo/bar/g' input.txt > output.txt
SOLUTION_EOF
chmod +x solution.sh
