#!/usr/bin/env bash
# bash-game level 21: Local Variables
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
square() {
  local n=$1
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
