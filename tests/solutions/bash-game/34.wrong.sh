#!/usr/bin/env bash
# bash-game level 34: Advanced Regex (WRONG)
# Mistake: the regex is far too lax (any line containing @), so "invalid@@mail" is written to emails.txt as well; grep -E is present but POST_CHECK_CMD (diff against the two valid addresses) rejects it ("Post-check command failed.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
grep -E '@' contacts.txt > emails.txt
SOLUTION_EOF
chmod +x solution.sh
