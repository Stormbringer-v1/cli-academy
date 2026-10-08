#!/usr/bin/env bash
# bash-game level 4: If/Then/Else (WRONG)
# Mistake: capitalises the words ("Positive"); the "if [[" pattern is satisfied but the exact-stdout check rejects it ("Unexpected stdout.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
read -r n
if [[ $n -gt 0 ]]; then
  echo Positive
elif [[ $n -lt 0 ]]; then
  echo Negative
else
  echo Zero
fi
SOLUTION_EOF
chmod +x solution.sh
