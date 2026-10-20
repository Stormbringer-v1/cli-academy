# CLI Academy

[![CI](https://github.com/Stormbringer-v1/cli-academy/actions/workflows/ci.yml/badge.svg)](https://github.com/Stormbringer-v1/cli-academy/actions/workflows/ci.yml)

Learn command-line tools by playing terminal games. Every level drops you into a real
shell with a real task; the engine checks what you actually did, not what you typed.
No mock environments, no multiple choice.

```bash
git clone https://github.com/Stormbringer-v1/cli-academy.git
cd cli-academy
./play.sh                 # pick a game from the menu
./play.sh bash-game       # or start one directly
```

The launcher shows which games your machine can run right now. Three games need nothing
beyond bash 4+, git and tmux; the rest need the tool they teach.

## Games

| Game | Levels | Needs | Status |
|---|---|---|---|
| [bash-game](games/bash-game/) | 41 | bash 4+ | Tested in CI |
| [git-game](games/git-game/) | 39 | git 2.20+ | Tested in CI |
| [tmux-game](games/tmux-game/) | 30 | tmux 3+ | Tested in CI |
| [docker-game](games/docker-game/) | 36 | Docker daemon | Playable, not yet in CI |
| [ssh-game](games/ssh-game/) | 27 | Docker, ssh, sshpass | Playable, not yet in CI |
| [sysops-game](games/sysops-game/) | 36 | Linux, procps, lsof, ss | Playable, not yet in CI |
| [systemd-game](games/systemd-game/) | 27 | Linux with a systemd user session | Playable, not yet in CI |
| [iptables-game](games/iptables-game/) | 33 | Linux, root, iptables, iproute2 | Playable, not yet in CI |
| [virsh-game](games/virsh-game/) | 27 | Linux, libvirt + KVM/QEMU | Playable, not yet in CI |
| [vim-game](games/vim-game/) | 46 | vim | Pending import from its original repository |

**Total: 296 levels across 9 playable games, plus vim-game to come.**

"Tested in CI" means every level has a scripted correct solution and deliberately wrong
solutions that run on every push. "Playable, not yet in CI" means the levels follow the
engine contract and pass the structural lint, but their tools are not available on the CI
runner, so they have only been exercised by hand. Expect some rough edges there; known ones
are listed in [tests/known-issues/](tests/known-issues/) and [docs/IMPROVEMENTS.md](docs/IMPROVEMENTS.md).

## Playing

Each game directory has its own `play.sh`:

```bash
cd games/git-game
./play.sh                 # play from the first level you haven't finished
./play.sh status          # list levels, see what you've completed
./play.sh hint 12         # hint for level 12 (boss levels are boss01, boss02, ...)
./play.sh replay 12       # play one level again
./play.sh reset           # wipe your progress for this game
./play.sh help
```

A level works like this:

1. The engine prints the mission and drops you into a shell inside a fresh, throwaway
   directory prepared for that level (a git repo with history, a running container, a tmux
   server, and so on).
2. You do the task with the real tool.
3. You type `exit`. The engine validates the result, tells you pass or fail, and cleans up
   everything it created, including on Ctrl-C.
4. Progress is saved per game in `progress.log` next to its `play.sh`.

Boss levels combine several skills; sysops-game uses checkpoints between tiers instead.

## Platform support

| Game | Linux | macOS | WSL |
|---|---|---|---|
| bash-game | yes | yes, with `brew install bash` (ships 3.2) | yes |
| git-game | yes | yes | yes |
| tmux-game | yes | yes | yes |
| docker-game | yes | Docker Desktop, untested | Docker Desktop, untested |
| ssh-game | yes | Docker Desktop, untested | untested |
| sysops-game | yes | partial (no /proc) | partial |
| systemd-game | yes | no | needs systemd enabled |
| iptables-game | yes, root | no | no |
| virsh-game | yes | no | no |

CI runs on Ubuntu with bash 5, git 2.55 and tmux 3.4.

## Project layout

```
cli-academy/
├── play.sh                 # launcher: menu, requirements check, hands over to a game
├── engine/                 # shared engine, sourced by every game's play.sh
│   ├── engine.sh           #   level lifecycle, sandbox, traps, commands, test mode
│   ├── validator.sh        #   validation types
│   └── ui.sh               #   colours, banners, prompts
├── games/<game>/
│   ├── play.sh             #   dependency checks + LEVEL_ORDER, then start_game
│   ├── game.conf           #   metadata
│   ├── *_common.sh         #   helpers sourced by that game's levels
│   └── levels/level<ID>/   #   level.conf, template.txt, hint.txt, sandbox.sh, validate.sh
├── tests/                  # lint, test harness, scripted solutions, known issues
├── docs/
│   ├── engine-contract.md  # how the engine and every level must behave (binding)
│   ├── IMPROVEMENTS.md     # what to work on next, with priorities
│   ├── sprint-1.md         # what was fixed in the first sprint and how it was verified
│   └── plan.md             # original vision and game catalogue
└── .github/workflows/ci.yml
```

## Development

The engine and every level follow [docs/engine-contract.md](docs/engine-contract.md). The
tooling that enforces it:

```bash
shellcheck -S warning engine/*.sh games/*/*.sh play.sh   # style and correctness
tests/lint-levels.sh                  # structural rules for every level of every game
tests/harness-selftest.sh             # the test harness checks itself
tests/run-game.sh bash-game           # run every scripted solution for one game
games/git-game/play.sh test 12 tests/solutions/git-game/12.sh   # one level, one solution
```

All of that runs in CI on every push and pull request. See [CONTRIBUTING.md](CONTRIBUTING.md)
for how to add or fix a level, and [tests/README.md](tests/README.md) for the harness.

## Roadmap

[docs/IMPROVEMENTS.md](docs/IMPROVEMENTS.md) lists what is worth doing next, from player
experience to content fixes to CI coverage for the infra games, each with a priority and
the files involved.

## License

MIT, see [LICENSE](LICENSE).

## Author

Robert Harutyunyan, [SnapSecurity](https://snapsecurity.org).
