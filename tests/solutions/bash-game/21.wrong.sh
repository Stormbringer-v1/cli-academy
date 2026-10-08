#!/usr/bin/env bash
# bash-game level 21: Local Variables (WRONG)
# Mistake: assigns n inside the function without the local keyword, so it leaks into the global scope; REQUIRED_PATTERNS rejects it ("Missing required pattern in solution.sh: local...").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
square() {
  n=$1
  RESULT=$((n * n))
}
square 4
if [[ -z ${n+x} ]]; then
  echo unset
else
  echo "n leaked: $n"
fi
SOLUTION_EOF
chmod +x solution.sh
