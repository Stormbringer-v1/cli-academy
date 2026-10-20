# What to improve next

A working list for whoever picks up the project after sprint 1. Each item says why it
matters, where the code is, and roughly how big it is. Priorities: **P1** blocks a good
player experience or hides real bugs; **P2** makes the project noticeably better; **P3**
is polish or longer-term.

Verified state this list starts from (2026-10): engine contract v2 implemented; all nine
games lint-clean; bash, git and tmux fully covered by scripted solutions in CI; the six
infra games converted but only hand-verified; vim-game not yet imported.

## 1. Player experience

| P | Item | Why | Where |
|---|---|---|---|
| P1 | In-shell `hint` and `task` commands | Today a stuck player must `exit` (which fails the level) and run `./play.sh hint N`. Give the level shell an rcfile that defines `hint` (prints hint.txt) and `task` (re-prints the template), and a prompt like `[git-game L12] $` so players know they are inside a level. | `engine/engine.sh` (where `eval "$TOOL_CMD"` runs for `TOOL_CMD="bash"`); contract §6 |
| P1 | Let `help`, `hint` and `status` work without the game's tools | docker, ssh, iptables, virsh run their dependency checks before anything else, so a player without Docker cannot even read a hint. Move the checks into play/replay/test only. | each `games/*/play.sh` (or a shared engine hook) |
| P2 | `skip` command | Lets a player move past a level they cannot do without resetting. Record it as skipped, not completed, and show it in `status`. | `engine/engine.sh` §6, `ui.sh` |
| P2 | Progress under `~/.local/share/cli-academy/<game>.progress` | Progress currently lives next to `play.sh`, so it is lost on re-clone and tied to one checkout. Honour `$XDG_DATA_HOME`. | contract §5, `engine/engine.sh`, `.gitignore` |
| P2 | Attempts, time and hint use per level | Cheap to record in the progress file; later feeds a scoreboard, the website and certificates. | contract §5, `engine/engine.sh` |
| P3 | A short "why it worked" after a pass | One paragraph per level explaining the concept. Add `explain.txt` as an optional sixth level file. | contract §1, `engine/engine.sh`, lint rule |
| P3 | Tiered hints | `hint.txt` today is often the exact command. Split into concept first, command second (`hint.txt`, `hint2.txt`). 47 hints are verbatim lines from the template. | all `levels/*/hint.txt`, lint |

## 2. Content quality

Each game's `tests/known-issues/<game>.md` has reproducible entries with evidence and a
suggested fix. The ones still open:

| P | Game | Levels | Problem |
|---|---|---|---|
| P1 | git | 21 | Template rebases a branch the sandbox never creates and the command conflicts even when it exists. Needs a redesigned setup and template. |
| P1 | git | 14 | Template promises a merge conflict the setup never creates; validator accepts any third commit. Start the merge in setup so the player really resolves it. |
| P2 | git | 8, 9, 20, 22, 27, 28, 31, 34, boss02 | Validator-weak: a partial or wrong answer passes (details in the file). Level 31's hook validator passes any executable hook. |
| P2 | bash | 4, 9, boss01, 14, 17, 20, 27 | Validator-weak: only one input tested, ordering not checked, required-pattern regexes match comments. Level 27 uses a fixed `/tmp/bashgame_trap_file`, which breaks parallel runs. |
| P2 | bash | 6, 12, 35 | Hint or template contradicts the validator (`read -r name` rejected; the hint's own command fails the exit-code check; `grep` without `-h` fails the post-check). |
| P2 | tmux | 3, 8, 15, 19, 20, 23, 25, 26, 27 | Validator-weak: a no-op passes level 3; `kill-server` passes 8; an empty executable script passes 25 and 27; hooks and prefix settings are never checked against the live server. |
| P2 | sysops | 9 | Setup writes `answer.txt` itself, so the level auto-passes. |
| P2 | sysops, iptables | 11 answer-file-only levels | Validators only check that `answer.txt` contains something; check real state instead (`iptables -C` in the namespace, process state). 20 of 33 iptables templates and 14 of 36 sysops templates print the exact command to type. |
| P3 | all | templates that give the answer | Beginner levels can show the command; intermediate and up should describe the goal. |

Rule adopted in sprint 1 that still needs applying to older validators and solutions:
never parse human-readable git or tmux output (git 2.55 changed the bisect message and broke
CI once). Use refs, plumbing, `--porcelain`/`--format`, and exit codes. Known offenders:
git level 8's validator (`git status` text), boss02's validator (`git branch` text),
solutions `25.sh` and `35.sh` (reflog subjects).

## 3. Testing and CI

| P | Item | Why | Where |
|---|---|---|---|
| P1 | docker-game solutions and CI job | GitHub's Ubuntu runners have Docker, so docker-game can join the matrix today. 36 levels need `<ID>.sh` and `.wrong.sh` scripts. | `tests/solutions/docker-game/`, `.github/workflows/ci.yml` matrix |
| P1 | Solutions for sysops and systemd, run in CI | Both work on a plain Ubuntu runner (systemd user session needs `systemd --user` enabled on the runner, or a container with systemd as PID 1). | `tests/solutions/`, workflow |
| P2 | An `ubuntu-22.04` matrix entry | Covers an older git and tmux alongside `ubuntu-latest`, so message-format and flag drift is caught both ways. | `.github/workflows/ci.yml` |
| P2 | Delete the harness `--legacy` mode | It drove the old engine through stdin and is dead now that test mode exists; its self-test expectations describe old bugs. | `tests/run-level.sh`, `tests/harness-selftest.sh`, `tests/README.md` |
| P2 | Harness self-test check 15 | Snapshots `/tmp/cla.*` before and after, so a concurrent harness run causes a false failure. Isolate per process. | `tests/harness-selftest.sh`, `tests/run-level.sh` §7.3 |
| P3 | Lint gaps | `rm -f -r` (split flags) is not caught; command substitutions inside top-level assignments other than the `$(cd ... && pwd)` idiom are neither run nor reported. | `tests/lint-levels.sh` |
| P3 | `NEEDS_DIR` removal | Ignored by the engine since contract v2; 173 `level.conf` files still set it. Remove and add a lint rule that forbids it. | `games/*/levels/*/level.conf`, `tests/lint-levels.sh` |
| P3 | `validate_solution.sh` temp files | bash-game's shared validator creates its capture files with fixed `/tmp` templates, ignoring `TMPDIR`. | `games/bash-game/validate_solution.sh` |

## 4. Infra games (docker, ssh, iptables, sysops, systemd, virsh)

| P | Item | Why | Where |
|---|---|---|---|
| P1 | Verify each on a real Linux host | Converted and lint-clean, but never run end to end since the conversion. Play every level once; file findings in `tests/known-issues/<game>.md`. | all six games |
| P1 | ssh-game and the player's real `~/.ssh` | Levels still `mkdir -p ~/.ssh`, level 7 may create a real `id_ed25519`, and every level pollutes `known_hosts` with changing host keys for `127.0.0.1:22xx`. Use a per-level `HOME` or `-o UserKnownHostsFile` inside `SANDBOX_DIR`. | `games/ssh-game/levels/*/sandbox.sh`, templates |
| P2 | Pin the ssh-game Docker image | `lscr.io/linuxserver/openssh-server:latest` is unpinned, and the fallback image probably does not exist. Pin a tag, drop the fallback. | `games/ssh-game/ssh_common.sh` |
| P2 | Docker prefix consistency | `cliacademy_l24/l25/l26/l32/boss03` lack the trailing underscore the other prefixes have. Harmless today, inconsistent. | `games/docker-game/levels/*/sandbox.sh` |
| P2 | A container image for the privileged games | iptables, systemd and virsh need root, a systemd PID 1 or libvirt. A dev container (or a documented `docker run --privileged` recipe) lets macOS and WSL users play them. | new `Dockerfile`, README |
| P3 | Per-game README refresh | The iptables, sysops and virsh READMEs predate the engine rewrite: command lists lack `status`/`test`, and level ranges should be checked against `LEVEL_ORDER`. | `games/*/README.md` |

## 5. vim-game

| P | Item | Why | Where |
|---|---|---|---|
| P1 | Import vim-game as a normal game | It is the original and most polished game (46 levels) but lives in a separate repository; this repo has only a placeholder. Convert its single-script levels to the `levels/level<ID>/` layout, write solutions (vim can be driven with `vim -es` or `-c` commands), add it to CI. | `games/vim-game/`, source: github.com/Stormbringer-v1/vim-game |

## 6. Documentation

| P | Item | Why | Where |
|---|---|---|---|
| P2 | Rewrite `docs/plan.md` | Still the original vision with every phase "not started" and a vim-game audit that is now history. Keep the game catalogue and level maps, drop the stale engine design and phase tables, point at the contract. | `docs/plan.md` |
| P3 | A short screencast or asciinema recording in the README | Shows what a level feels like better than prose. | `README.md` |

## 7. Longer term (from the original plan)

- A web platform (academy.snapsecurity.org) that reads the per-level progress data.
- Certifications per game, gated on completing every level including bosses.
- More games: the plan listed htop (now sysops), and ideas like `jq`, `awk`/`sed`, `curl`, `kubectl`.

## How to pick something up

1. Pick an item, create a branch from `main`.
2. For content fixes, start from the known-issues entry: it has the reproduction and a suggested fix.
3. Run `tests/lint-levels.sh <game>` and `tests/run-game.sh <game>` before pushing; CI runs them again.
4. Update this file: remove what you fixed, add what you found.
