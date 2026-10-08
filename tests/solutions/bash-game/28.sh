#!/usr/bin/env bash
# bash-game level 28: Background Jobs
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
sleep 0.2 &
sleep 0.2 &
wait
echo done
SOLUTION_EOF
chmod +x solution.sh
