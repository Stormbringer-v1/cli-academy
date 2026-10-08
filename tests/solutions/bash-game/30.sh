#!/usr/bin/env bash
# bash-game level 30: getopts
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
name=""
env_name=""
while getopts "n:e:" opt; do
  case "$opt" in
    n) name=$OPTARG ;;
    e) env_name=$OPTARG ;;
    *) exit 2 ;;
  esac
done
echo "$name:$env_name"
SOLUTION_EOF
chmod +x solution.sh
