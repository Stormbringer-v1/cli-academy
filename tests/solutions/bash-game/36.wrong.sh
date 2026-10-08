#!/usr/bin/env bash
# bash-game level 36: Debugging (WRONG)
# Mistake: enables set -x and sets PS4 but forgets the DEBUG trap; the output is right but REQUIRED_PATTERNS rejects it ("Missing required pattern in solution.sh: trap...DEBUG").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
PS4='+ line ${LINENO}: '
set -x
echo "debug complete"
SOLUTION_EOF
chmod +x solution.sh
