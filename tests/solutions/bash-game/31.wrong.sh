#!/usr/bin/env bash
# bash-game level 31: Error Handling Patterns (WRONG)
# Mistake: uses only "set -e" instead of the full "set -euo pipefail"; the output is right but REQUIRED_PATTERNS rejects it ("Missing required pattern in solution.sh: set...-euo...pipefail").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
set -e
echo safe
SOLUTION_EOF
chmod +x solution.sh
