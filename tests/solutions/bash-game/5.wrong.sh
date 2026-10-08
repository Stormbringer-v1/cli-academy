#!/usr/bin/env bash
# bash-game level 5: Test Expressions (WRONG)
# Mistake: uses the single-bracket test [ -f marker.txt ] instead of [[ -f marker.txt ]]; the output is right but REQUIRED_PATTERNS rejects it ("Missing required pattern in solution.sh: \[\[...").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
if [ -f marker.txt ]; then
  echo "file exists"
fi
SOLUTION_EOF
chmod +x solution.sh
