#!/usr/bin/env bash
# bash-game level 13: Here Documents
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
cat > config.ini <<EOF
[app]
port=8080
EOF
SOLUTION_EOF
chmod +x solution.sh
