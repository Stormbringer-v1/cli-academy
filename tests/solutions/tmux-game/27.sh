#!/usr/bin/env bash
# tmux-game level 27: FINAL BOSS - Development Environment
set -euo pipefail

# The reusable bootstrap script.
cat > bootstrap.sh <<'BOOT_EOF'
#!/usr/bin/env bash
set -euo pipefail

# Session with four windows; the first one (editor) is split into two panes.
tmuxa new-session -d -s academy -n editor
tmuxa split-window -h -t academy:editor
tmuxa new-window -t academy: -n server
tmuxa new-window -t academy: -n logs
tmuxa new-window -t academy: -n shell

# Global options.
tmuxa set-option -g status-right LIVE
tmuxa set-option -g mouse on
BOOT_EOF

chmod +x bootstrap.sh
./bootstrap.sh
