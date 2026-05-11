#!/usr/bin/env bash
        set -euo pipefail

        TMUX_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        source "${TMUX_GAME_ROOT}/validate_tmux_state.sh"

        if [[ -x bootstrap.sh ]] && tmux_session_exists academy           && [[ "$(tmux_window_count academy)" -eq 4 ]]           && tmux_window_exists academy editor           && tmux_window_exists academy server           && tmux_window_exists academy logs           && tmux_window_exists academy shell           && [[ "$(tmux_pane_count academy:editor)" -eq 2 ]]           && tmux_global_option_equals status-right LIVE           && tmux_global_option_equals mouse on; then
  exit 0
fi
echo "Expected academy session with editor/server/logs/shell, editor split, status-right LIVE, mouse on, and executable bootstrap.sh."
exit 1
