#!/usr/bin/env bash
# tmux-game level 25: tmux scripting (WRONG)
# Mistake: forgets chmod +x and runs the script with "bash layout.sh"; the state is right but the validator requires layout.sh to be executable.
set -euo pipefail

cat > layout.sh <<'LAYOUT_EOF'
#!/usr/bin/env bash
set -euo pipefail

tmuxa new-session -d -s dev -n editor
tmuxa new-window -t dev: -n server
tmuxa new-window -t dev: -n logs
LAYOUT_EOF

bash layout.sh
