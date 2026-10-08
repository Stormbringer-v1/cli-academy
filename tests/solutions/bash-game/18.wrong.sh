#!/usr/bin/env bash
# bash-game level 18: cut/paste/tr (WRONG)
# Mistake: the cut | tr pipeline is right but its output is never redirected into upper.txt; POST_CHECK_CMD rejects the missing file ("Post-check command failed.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
cut -d, -f1 data.csv | tr '[:lower:]' '[:upper:]'
SOLUTION_EOF
chmod +x solution.sh
