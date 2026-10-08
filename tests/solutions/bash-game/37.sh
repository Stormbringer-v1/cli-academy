#!/usr/bin/env bash
# bash-game level 37: FINAL BOSS - Deployment Script
set -euo pipefail
cat > solution.sh <<'SOLUTION_EOF'
#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: ${0##*/} -e ENV -c CONFIG" >&2
  exit 2
}

env_name=""
config=""
while getopts "e:c:" opt; do
  case "$opt" in
    e) env_name=$OPTARG ;;
    c) config=$OPTARG ;;
    *) usage ;;
  esac
done

[[ -n $env_name && -n $config ]] || usage
if [[ ! -f $config ]]; then
  echo "config file not found: $config" >&2
  exit 1
fi

staging=$(mktemp)
cleanup() {
  rm -f "$staging"
}
trap cleanup EXIT

cp "$config" "$staging"
echo "deploy $env_name ok"
SOLUTION_EOF
chmod +x solution.sh
