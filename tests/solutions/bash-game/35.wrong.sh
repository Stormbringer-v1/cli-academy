#!/usr/bin/env bash
# bash-game level 35: find + exec (WRONG)
# Mistake: runs grep without -h, so with two .log files every line is prefixed with its file name (logs/a.log:ERROR one) and no line starts with ERROR; find and -exec are present but POST_CHECK_CMD (grep -c '^ERROR' >= 2) rejects it ("Post-check command failed.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
find logs -name '*.log' -exec grep 'ERROR' {} + > errors.txt
SOLUTION_EOF
chmod +x solution.sh
