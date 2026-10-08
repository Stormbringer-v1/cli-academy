#!/usr/bin/env bash
# bash-game level 0: Echo and Exit (WRONG)
# Mistake: copies "exit 1" from an error-handling snippet, so the script exits non-zero; rejected by the exit-code check ("Unexpected exit code. Expected 0, got 1").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
echo hello
exit 1
SOLUTION_EOF
chmod +x solution.sh
