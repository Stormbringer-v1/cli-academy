#!/usr/bin/env bash
# bash-game level 37: FINAL BOSS - Deployment Script (WRONG)
# Mistake: parses the options, checks the config file and prints the right line, but never registers an EXIT trap for cleanup; REQUIRED_PATTERNS rejects it ("Missing required pattern in solution.sh: trap").
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
set -euo pipefail

env_name=""
config=""
while getopts "e:c:" opt; do
  case "$opt" in
    e) env_name=$OPTARG ;;
    c) config=$OPTARG ;;
    *) exit 2 ;;
  esac
done

if [[ ! -f $config ]]; then
  echo "config file not found: $config" >&2
  exit 1
fi
echo "deploy $env_name ok"
SOLUTION_EOF
chmod +x solution.sh
