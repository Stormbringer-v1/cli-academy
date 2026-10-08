#!/usr/bin/env bash
        set -euo pipefail

        if [[ -z "${TMUX_SOCKET:-}" ]]; then
          echo "TMUX_SOCKET is not set."
          exit 1
        fi

        tmuxa() {
          tmux -L "$TMUX_SOCKET" "$@"
        }

        tmux_session_exists() {
          tmuxa has-session -t "=$1" 2>/dev/null
        }

        tmux_window_count() {
          { tmuxa list-windows -t "$1" 2>/dev/null || true; } | wc -l | tr -d ' '
        }

        tmux_window_exists() {
          tmuxa list-windows -t "$1" -F '#W' 2>/dev/null | grep -Fxq "$2"
        }

        tmux_active_window_name() {
          tmuxa display-message -p -t "$1" '#W'
        }

        tmux_pane_count() {
          { tmuxa list-panes -t "$1" 2>/dev/null || true; } | wc -l | tr -d ' '
        }

        tmux_client_count() {
          { tmuxa list-clients -t "$1" 2>/dev/null || true; } | wc -l | tr -d ' '
        }

        tmux_capture_contains() {
          tmuxa capture-pane -p -t "$1" 2>/dev/null | grep -Fq "$2"
        }

        tmux_global_option_equals() {
          [[ "$(tmuxa show-options -gqv "$1" 2>/dev/null || true)" == "$2" ]]
        }

        tmux_window_option_equals() {
          [[ "$(tmuxa show-options -wqv -t "$1" "$2" 2>/dev/null || true)" == "$3" ]]
        }

        tmux_buffer_equals() {
          [[ "$(tmuxa show-buffer 2>/dev/null || true)" == "$1" ]]
        }

        tmux_hook_output_contains() {
          tmuxa show-hooks -g 2>/dev/null | grep -Fq "$1"
        }

        tmux_current_pane_index() {
          tmuxa display-message -p -t "$1" '#{pane_index}'
        }

        tmux_window_zoomed() {
          [[ "$(tmuxa display-message -p -t "$1" '#{window_zoomed_flag}')" == "1" ]]
        }

        tmux_two_pane_orientation() {
          local target=$1
          local expected=$2
          local pane_lines pane1 pane2 left1 top1 left2 top2
          pane_lines="$(tmuxa list-panes -t "$target" -F '#{pane_left} #{pane_top}' 2>/dev/null || true)"
          pane1="$(printf '%s
' "$pane_lines" | sed -n '1p')"
          pane2="$(printf '%s
' "$pane_lines" | sed -n '2p')"
          [[ -n "$pane1" && -n "$pane2" ]] || return 1

          read -r left1 top1 <<<"$pane1"
          read -r left2 top2 <<<"$pane2"

          case "$expected" in
            horizontal)
              [[ "$left1" == "$left2" && "$top1" != "$top2" ]]
              ;;
            vertical)
              [[ "$top1" == "$top2" && "$left1" != "$left2" ]]
              ;;
            *)
              return 1
              ;;
          esac
        }

        tmux_left_pane_wider() {
          local target=$1
          local pane_lines pane1 pane2 width0 width1
          pane_lines="$(tmuxa list-panes -t "$target" -F '#{pane_index} #{pane_width}' 2>/dev/null | sort -n || true)"
          pane1="$(printf '%s
' "$pane_lines" | sed -n '1p')"
          pane2="$(printf '%s
' "$pane_lines" | sed -n '2p')"
          [[ -n "$pane1" && -n "$pane2" ]] || return 1
          read -r _ width0 <<<"$pane1"
          read -r _ width1 <<<"$pane2"
          (( width0 > width1 + 4 ))
        }

        tmux_all_panes_equal_height() {
          local target=$1
          local heights_text count=0 base="" h diff
          heights_text="$(tmuxa list-panes -t "$target" -F '#{pane_height}' 2>/dev/null || true)"
          [[ -n "$heights_text" ]] || return 1
          base="$(printf '%s
' "$heights_text" | sed -n '1p')"
          while IFS= read -r h; do
            [[ -n "$h" ]] || continue
            count=$((count + 1))
            diff=$(( h > base ? h - base : base - h ))
            (( diff <= 2 )) || return 1
          done <<EOF
$heights_text
EOF
          (( count > 1 ))
        }
