#!/usr/bin/env bash
# bash-game level boss01: BOSS 01 - Shell Basics (WRONG)
# Mistake: the countdown loop runs down to 0 (i >= 0) instead of stopping at 1; all required patterns are present but the exact-stdout check rejects the extra "0" line ("Unexpected stdout.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
read -r n
if [[ $n -gt 0 ]]; then
  echo positive
elif [[ $n -lt 0 ]]; then
  echo negative
else
  echo zero
fi
for ((i = n; i >= 0; i--)); do
  echo "$i"
done
SOLUTION_EOF
chmod +x solution.sh
