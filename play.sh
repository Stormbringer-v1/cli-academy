#!/usr/bin/env bash
# CLI Academy launcher.
#
#   ./play.sh                    pick a game from a menu
#   ./play.sh <game> [args...]   run games/<game>/play.sh (e.g. ./play.sh bash-game status)
#   ./play.sh list               show every game with its requirements status and your progress
#   ./play.sh help               this text
#
# Each game is self-contained under games/<game>/ and can also be started directly with
# games/<game>/play.sh. This script only finds games, checks whether their dependencies are
# present, and hands over.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAMES_DIR="$ROOT/games"

# shellcheck source=engine/ui.sh
source "$ROOT/engine/ui.sh"

usage() {
  cat <<'USAGE'
Usage: ./play.sh [game [args...] | list | help]

  (no arguments)        Choose a game from a menu
  <game> [args...]      Run that game, e.g. ./play.sh bash-game  or  ./play.sh git-game status
  list                  Show all games, whether their requirements are met, and your progress
  help                  Show this help

Games live in games/<game>/ and each one also works on its own: games/bash-game/play.sh
USAGE
}

# All game directories that have a play.sh, sorted.
game_names() {
  local d
  for d in "$GAMES_DIR"/*/; do
    [[ -f "$d/play.sh" ]] || continue
    basename "$d"
  done
}

# Number of levels a game ships (directories named levels/level<ID>).
level_count() {
  local n=0 d
  for d in "$GAMES_DIR/$1"/levels/level*/; do
    [[ -d "$d" ]] && n=$((n + 1))
  done
  echo "$n"
}

# Number of levels recorded as completed in the game's progress file.
completed_count() {
  local f="$GAMES_DIR/$1/progress.log"
  if [[ -f "$f" ]]; then
    grep -c '=completed$' "$f" || true
  else
    echo 0
  fi
}

# Runs the game's own dependency checks by asking it for help. Prints "ready" or the first
# line of the game's complaint. A game whose play.sh exits 2 on `help` is missing a dependency.
availability() {
  local out rc
  out="$(cd "$GAMES_DIR/$1" && timeout 20 ./play.sh help 2>&1 </dev/null)"
  rc=$?
  if [[ $rc -eq 0 ]]; then
    echo "ready"
  else
    printf '%s\n' "$out" | grep -m1 -E 'Error|error|not found|not running|requires' \
      | sed -E 's/^[^A-Za-z]*//; s/^Error: //' | cut -c1-60
  fi
}

print_table() {
  local name total finished avail
  printf '  %-3s %-15s %-9s %s\n' "#" "GAME" "PROGRESS" "REQUIREMENTS"
  local i=0
  for name in $(game_names); do
    i=$((i + 1))
    total="$(level_count "$name")"
    finished="$(completed_count "$name")"
    avail="$(availability "$name")"
    if [[ "$avail" == "ready" ]]; then
      printf '  %-3s %-15s %3s/%-5s %s\n' "$i" "$name" "$finished" "$total" "${GREEN}ready${NC}"
    else
      printf '  %-3s %-15s %3s/%-5s %s\n' "$i" "$name" "$finished" "$total" "${YELLOW}missing: ${avail}${NC}"
    fi
  done
  if [[ -d "$GAMES_DIR/vim-game" && ! -f "$GAMES_DIR/vim-game/play.sh" ]]; then
    printf '  %-3s %-15s %-9s %s\n' "-" "vim-game" "-" "${DIM}not imported yet (see games/vim-game/README.md)${NC}"
  fi
}

run_game() {
  local name="$1"; shift
  if [[ ! "$name" =~ ^[a-z0-9-]+$ || ! -f "$GAMES_DIR/$name/play.sh" ]]; then
    msg_fail "Unknown game: $name"
    echo ""
    echo "Available games:"
    game_names | sed 's/^/  /'
    exit 2
  fi
  exec "$GAMES_DIR/$name/play.sh" "$@"
}

menu() {
  banner "CLI Academy"
  echo "Learn command-line tools by playing. Pick a game:"
  echo ""
  print_table
  echo ""
  local names=() choice
  mapfile -t names < <(game_names)
  read -r -p "Game number (or q to quit): " choice || { echo ""; exit 0; }
  if [[ "$choice" =~ ^[qQ]$ || -z "$choice" ]]; then
    exit 0
  fi
  if [[ ! "$choice" =~ ^[0-9]+$ || "$choice" -lt 1 || "$choice" -gt ${#names[@]} ]]; then
    msg_fail "Pick a number between 1 and ${#names[@]}."
    exit 2
  fi
  run_game "${names[$((choice - 1))]}"
}

case "${1:-}" in
  "")            menu ;;
  list|ls)       print_table ;;
  help|-h|--help) usage ;;
  *)             run_game "$@" ;;
esac
