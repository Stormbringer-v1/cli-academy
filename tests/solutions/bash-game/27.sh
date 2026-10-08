#!/usr/bin/env bash
# bash-game level 27: Traps
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
marker=/tmp/bashgame_trap_file
cleanup() {
  rm -f "$marker"
  echo cleaned
}
trap cleanup EXIT
touch "$marker"
exit 0
SOLUTION_EOF
chmod +x solution.sh
