#!/usr/bin/env bash
# bash-game level 12: Stderr Redirection (WRONG)
# Mistake: redirects stdout (> errors.log) instead of stderr (2> errors.log); REQUIRED_PATTERNS rejects it ("Missing required pattern in solution.sh: 2>...errors.log").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
ls missing-file > errors.log || true
SOLUTION_EOF
chmod +x solution.sh
