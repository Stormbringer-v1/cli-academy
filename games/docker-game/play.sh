#!/usr/bin/env bash
set -euo pipefail

# docker-game: Learn Docker through isolated prefixed resources

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is not installed."
  echo "Install Docker and try again."
  echo "  macOS: install Docker Desktop"
  echo "  Ubuntu/Debian: sudo apt install docker.io"
  echo "  Fedora: sudo dnf install docker"
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker is installed but the daemon is not running."
  echo "Start Docker Desktop or your docker service and try again."
  exit 1
fi

LEVEL_ORDER=(
  0 1 2 3 4 5 6 7 8 9
  boss01
  10 11 12 13 14 15 16 17 18 19
  boss02
  20 21 22 23 24 25 26 27
  boss03
  28 29 30 31 32
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_PATH="$SCRIPT_DIR/../../engine/engine.sh"

if [[ ! -f "$ENGINE_PATH" ]]; then
  echo "Error: Game engine not found at $ENGINE_PATH"
  exit 1
fi

source "$ENGINE_PATH"
start_game "$@"
