#!/usr/bin/env bash
# tmux-game level 27: FINAL BOSS - Development Environment (WRONG)
# Mistake: the bootstrap script never turns the global mouse option on; every other requirement is met, so the mouse check is what rejects it.
set -euo pipefail

cat > bootstrap.sh <<'BOOT_EOF'
#!/usr/bin/env bash
set -euo pipefail

tmuxa new-session -d -s academy -n editor
tmuxa split-window -h -t academy:editor
tmuxa new-window -t academy: -n server
tmuxa new-window -t academy: -n logs
tmuxa new-window -t academy: -n shell
tmuxa set-option -g status-right LIVE
BOOT_EOF

chmod +x bootstrap.sh
./bootstrap.sh
