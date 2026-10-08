#!/usr/bin/env bash
# bash-game level 20: Functions
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
greet() {
  echo "hello devops"
}
greet
SOLUTION_EOF
chmod +x solution.sh
