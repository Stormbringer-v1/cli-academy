#!/usr/bin/env bash
# tmux-game level 25: tmux scripting
set -euo pipefail

# The reusable script: one session, three named windows.
cat > layout.sh <<'LAYOUT_EOF'
#!/usr/bin/env bash
set -euo pipefail

tmuxa new-session -d -s dev -n editor
tmuxa new-window -t dev: -n server
tmuxa new-window -t dev: -n logs
LAYOUT_EOF

chmod +x layout.sh
./layout.sh
