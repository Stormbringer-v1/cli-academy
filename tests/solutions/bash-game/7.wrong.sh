#!/usr/bin/env bash
# bash-game level 7: For Loops (WRONG)
# Mistake: off-by-one in the word list (only 1 and 2); the "for ... in" pattern is satisfied but the exact-stdout check rejects it ("Unexpected stdout.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
for i in 1 2; do
  echo "$i"
done
SOLUTION_EOF
chmod +x solution.sh
