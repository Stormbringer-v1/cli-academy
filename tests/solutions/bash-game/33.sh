#!/usr/bin/env bash
# bash-game level 33: String Manipulation
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
path=/opt/app/config.yaml
file=${path##*/}
echo "${file%%.*}"
SOLUTION_EOF
chmod +x solution.sh
