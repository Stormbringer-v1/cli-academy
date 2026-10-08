#!/usr/bin/env bash

tmux_game_init() {
  export TMUX_SOCKET="${TMUX_SOCKET:-tmuxgame_${PPID}_${RANDOM}}"
  tmuxa() {
    tmux -L "$TMUX_SOCKET" "$@"
  }
  export -f tmuxa
  export TMUX_SOCKET
  tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true
}

tmux_game_cleanup() {
  if [[ -n "${TMUX_SOCKET:-}" ]]; then
    tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true
  fi
}
