#!/usr/bin/env bash
# bash-game level 30: getopts (WRONG)
# Mistake: reads the arguments by position ($2, $4) instead of parsing them with getopts; the output is right but REQUIRED_PATTERNS rejects it ("Missing required pattern in solution.sh: getopts").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
name=$2
env_name=$4
echo "$name:$env_name"
SOLUTION_EOF
chmod +x solution.sh
