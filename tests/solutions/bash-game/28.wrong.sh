#!/usr/bin/env bash
# bash-game level 28: Background Jobs (WRONG)
# Mistake: starts the two background jobs but never calls wait before printing; REQUIRED_PATTERNS rejects it ("Missing required pattern in solution.sh: wait").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
sleep 0.2 &
sleep 0.2 &
echo done
SOLUTION_EOF
chmod +x solution.sh
