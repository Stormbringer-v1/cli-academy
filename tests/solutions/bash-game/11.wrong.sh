#!/usr/bin/env bash
# bash-game level 11: Stdout Redirection (WRONG)
# Mistake: writes "Deployment complete" with a capital D into report.txt; the redirect pattern is satisfied but POST_CHECK_CMD (grep -qx 'deployment complete') rejects it ("Post-check command failed.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
echo "Deployment complete" > report.txt
SOLUTION_EOF
chmod +x solution.sh
