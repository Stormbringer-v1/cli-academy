#!/usr/bin/env bash
# bash-game level boss02: BOSS 02 - Log Pipeline (WRONG)
# Mistake: the final sort is ascending (sort -n) instead of highest count first (sort -rn); all patterns are present but POST_CHECK_CMD (diff against "3 AUTH / 2 DB / 1 API") rejects report.txt ("Post-check command failed.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
grep '^ERROR' app.log \
  | awk '{print $2}' \
  | sort \
  | uniq -c \
  | sort -n \
  | awk '{print $1, $2}' > report.txt
SOLUTION_EOF
chmod +x solution.sh
