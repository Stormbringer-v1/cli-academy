# 🎮 CLI Academy — SnapSecurity

> Learn CLI tools by playing terminal games. No dependencies, no installs — just `git clone && ./play.sh`.

**Website:** [academy.snapsecurity.org](https://academy.snapsecurity.org) *(coming soon)*

---

## Games

| # | Game | Levels | Status |
|---|------|--------|--------|
| 1 | [vim-game](games/vim-game/) | 46 | ✅ Playable |
| 2 | [git-game](games/git-game/) | 38 | 🔧 In Progress |
| 3 | [bash-game](games/bash-game/) | 40 | 🔧 In Progress |
| 4 | tmux-game | 30 | ⏳ Planned |
| 5 | docker-game | 35 | ⏳ Planned |
| 6 | virsh-game | 25 | ⏳ Planned |
| 7 | iptables-game | 30 | ⏳ Planned |
| 8 | htop-game | 20 | ⏳ Planned |
| 9 | systemd-game | 25 | ⏳ Planned |
| 10 | ssh-game | 25 | ⏳ Planned |

**Total: 10 games, ~314 levels**

---

## Quick Start

```bash
# Clone
git clone https://github.com/Stormbringer-v1/cli-academy.git
cd cli-academy

# Play the vim game
cd games/vim-game
./play.sh

# Play the git game
cd games/git-game
./play.sh
```

## Commands

```bash
./play.sh              # Start from where you left off
./play.sh reset        # Reset all progress
./play.sh replay 5     # Replay level 5
./play.sh hint 5       # Show hint for level 5
```

## How It Works

Each game teaches a CLI tool through interactive terminal challenges:

1. **Read the mission** — what you need to accomplish
2. **Do the work** — use the actual tool (vim, git, bash, etc.)
3. **Get validated** — the engine checks if you did it correctly
4. **Level up** — move on to harder challenges

No mock environments. No tutorials. You learn by doing.

## Architecture

```
cli-academy/
├── engine/           # Shared game engine
│   ├── engine.sh     # Core: progress, level ordering, main loop
│   ├── validator.sh  # 5 validation types
│   └── ui.sh         # Colors, banners, prompts
├── games/
│   ├── vim-game/     # Learn Vim
│   ├── git-game/     # Learn Git
│   ├── bash-game/    # Learn Bash
│   └── ...
└── docs/
    └── plan.md       # Master plan
```

## Platform Support

| Game | Linux | macOS | WSL |
|------|-------|-------|-----|
| vim-game | ✅ | ✅ | ✅ |
| git-game | ✅ | ✅ | ✅ |
| bash-game | ✅ | ✅ | ✅ |
| docker-game | ✅ | ✅ | ✅ |
| virsh-game | ✅ | ❌ | ⚠️ |
| iptables-game | ✅ | ❌ | ❌ |
| systemd-game | ✅ | ❌ | ⚠️ |

## License

MIT — see [LICENSE](LICENSE)

## Author

Robert Harutyunyan — [SnapSecurity](https://snapsecurity.org)
