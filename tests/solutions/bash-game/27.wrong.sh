#!/usr/bin/env bash
# bash-game level 27: Traps (WRONG)
# Mistake: the EXIT trap works but prints "cleaned up" instead of exactly "cleaned"; the exact-stdout check rejects it ("Unexpected stdout.").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
trap 'rm -f /tmp/bashgame_trap_file; echo "cleaned up"' EXIT
touch /tmp/bashgame_trap_file
exit 0
SOLUTION_EOF
chmod +x solution.sh
