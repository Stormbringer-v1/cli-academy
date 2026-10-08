#!/usr/bin/env bash
# bash-game level 1: Variables (WRONG)
# Mistake: adds a comma to the greeting ("Hello, world"); the variable patterns are satisfied but the exact-stdout check rejects it ("Unexpected stdout.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
NAME=world
echo "Hello, $NAME"
SOLUTION_EOF
chmod +x solution.sh
