#!/usr/bin/env bash
# bash-game level boss03: BOSS 03 - Functions, Traps, Parallel (WRONG)
# Mistake: cleans up by calling rm -rf at the very end instead of registering an EXIT trap; function, array, wait and the output are all fine, but REQUIRED_PATTERNS rejects the missing trap ("Missing required pattern in solution.sh: trap").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
workdir=$(mktemp -d)

worker() {
  sleep 0.1
  echo "$1 finished" > "$workdir/$1.done"
}

tasks=(build test package)
for task in "${tasks[@]}"; do
  worker "$task" &
done
wait

finished=("$workdir"/*.done)
if (( ${#finished[@]} != ${#tasks[@]} )); then
  echo "some jobs did not finish" >&2
  exit 1
fi
rm -rf "$workdir"
echo "boss3 complete"
SOLUTION_EOF
chmod +x solution.sh
