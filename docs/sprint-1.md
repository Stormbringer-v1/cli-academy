# Sprint 1 — Engine hardening and a test harness

**Owner:** lead architect. **Teams:** development lead (Opus), testing lead (Opus),
Sonnet workers (max 6 concurrent per lead). **Branch:** `claude/ecstatic-curie-mwnnfs`.
**Contract:** `docs/engine-contract.md` is binding for all work in this sprint.

## Goal

After this sprint a player can finish any level of any game, fail a level and keep
playing, Ctrl-C without leaking resources, and a maintainer can run every level of
bash-game, git-game and tmux-game non-interactively in CI.

## Verified defects (2026-10-08 review)

| # | Defect | Evidence |
|---|---|---|
| B1 | Failing a level exits the game silently (no FAIL_MSG, no hint tip, no cleanup). `set -e` + validator called outside a conditional in `engine/engine.sh`. | bash-game, type `exit` → prints validator reason, exits 1 |
| B2 | Player shell exiting non-zero exits the game before validation. | `false; exit` → exits 1 |
| B3 | iptables, sysops, systemd, virsh never set `NEEDS_DIR`; their `sandbox.sh` cds into a temp dir that cleanup deletes; the engine never cds back. Level 2 lookup fails, masked by `local X="$(...)"`, engine falls back to `vim $TMP_FILE` + `content_check` with no rules → auto-pass. 123 levels. | reproduced with a synthetic 2-level game |
| B4 | Boss/checkpoint directories don't match `levels/level<ID>`: iptables `boss01-03`, systemd `boss01-02`, virsh `boss01-02`, sysops `checkpoint1-3`, `boss_final`. sysops `LEVEL_ORDER` lists levels 19, 29, 34 that don't exist. | `./play.sh hint boss01` → "No hint available" |
| B5 | `games/vim-game` is a mode-160000 gitlink with no `.gitmodules`; clones get an empty dir. | `git ls-files -s games/vim-game` |
| B6 | `play.sh` only works when cwd is the game dir (relative `levels/`, progress in cwd). | from repo root → vim launches |
| B7 | `ssh-game/play.sh`, `systemd-game/play.sh` not executable. | `find -name play.sh ! -perm -u+x` |
| B8 | No `trap` anywhere: Ctrl-C leaks containers, netns + host veth, tmux servers, sysops CPU burners. | grep |
| B9 | ssh-game `sandbox.sh` files run code at source time (containers started before `setup_sandbox`; level3 `keytest` never stopped); container names lack the `cliacademy_` prefix. | read |
| B10 | `sysops_common.sh` has 4 shellcheck errors (SC2068); sysops level 21 validator uses `\d` with `grep -E` (never matches). | shellcheck |
| B11 | `NAME`/`TIER` set in every `level.conf` but never shown; `ui_level_header`, `ui_progress`, `ui_continue_prompt` never called; continue prompt defaults to No. | grep |

## Development tickets (wave 1)

| Ticket | Scope | Fixes | Depends on |
|---|---|---|---|
| D-ENGINE | Implement contract §2–§7 in `engine/`: engine-owned `SANDBOX_DIR`, trap, drop `-e`, absolute paths from `$0`, whole-line progress match, `status`/`help`/`test` commands, header + progress display, default-yes prompt, setup errors exit 2. chmod +x the two play.sh. Remove the broken vim-game gitlink and leave a `games/vim-game/README.md` stub ("import pending"). | B1 B2 B5 B6 B7 B8 B11, B3 (engine side) | — |
| D-CONVERT-iptables | Rename `boss01-03` → `levelboss01-03`; strip mktemp/cd/rm/export-of-SANDBOX_DIR from all 33 `sandbox.sh`; move any top-level statements into functions; `iptables_common.sh` cleanup must not delete `SANDBOX_DIR`. | B3 B4 | contract only |
| D-CONVERT-sysops | Rename `checkpoint1-3`, `boss_final` → `levelcheckpoint1-3`, `levelboss_final`; fix `LEVEL_ORDER` (drop or create 19, 29, 34 — dev lead decides); strip sandbox dir handling from 36 `sandbox.sh`; fix SC2068 in `sysops_common.sh`; fix level 21 regex. | B3 B4 B10 | contract only |
| D-CONVERT-systemd | Rename `boss01-02`; strip sandbox dir handling from 27 `sandbox.sh`. | B3 B4 | contract only |
| D-CONVERT-virsh | Rename `boss01-02`; strip sandbox dir handling from 27 `sandbox.sh`. | B3 B4 | contract only |
| D-CONVERT-ssh | Strip sandbox dir handling from 27 `sandbox.sh`; move all top-level statements into `setup_sandbox`; every container started must be stopped in `cleanup_sandbox`; prefix container names with `cliacademy_`. | B3 B9 | contract only |

bash-game, git-game, tmux-game and docker-game already set `NEEDS_DIR="true"` and do
not manage directories themselves; they need no conversion.

## Testing tickets (wave 1)

| Ticket | Scope | Depends on |
|---|---|---|
| T-LINT | `tests/lint-levels.sh`: for every game, the 5 level files exist (validate.sh when type=script), `LEVEL_ORDER` == level dirs, naming per contract §1, `sandbox.sh` has no top-level statements beyond `source`/assignments, `validate.sh` has a failure path, shebangs, exec bits. Exit non-zero on any finding; readable report. | — |
| T-CI | `.github/workflows/ci.yml`: shellcheck per contract §9, `tests/lint-levels.sh`, and the harness for bash/git/tmux on `ubuntu-latest` (tmux installed via apt). | T-LINT, T-HARNESS |
| T-HARNESS | `tests/run-level.sh <game> <ID> <solution>` wrapping `play.sh test`; `tests/run-game.sh <game>` runs every `tests/solutions/<game>/<ID>.sh` and, if present, `<ID>.wrong.sh` (must fail); prints a pass/fail table and exits non-zero on any mismatch. | contract §7 (engine lands in D-ENGINE) |
| T-SOL-bash | `tests/solutions/bash-game/<ID>.sh` for all 41 levels + a `.wrong.sh` for at least 10. | T-HARNESS spec |
| T-SOL-git | Same for git-game (39). | T-HARNESS spec |
| T-SOL-tmux | Same for tmux-game (30). | T-HARNESS spec |

## Acceptance for the sprint

1. `shellcheck -S warning engine/*.sh games/*/*.sh` is clean.
2. `tests/lint-levels.sh` is clean for all games.
3. `tests/run-game.sh bash-game|git-game|tmux-game` all pass in this container and in CI.
4. Manual: in bash-game, fail level 0 → FAIL_MSG + hint tip + continue prompt; `false; exit` → same; Ctrl-C mid-level leaves no temp dirs.
5. Synthetic two-level game with a sandbox that only populates cwd plays both levels.

## Operating rules

- Every worker works in its own git worktree on its own branch, commits there, never pushes.
- Workers touch only the paths in their ticket. Engine changes go through D-ENGINE only.
- A lead reviews each worker's diff before the architect merges it; nothing merges red.
- Reports to the architect use: **Done / Blocked / Needs decision**, with branch + SHA.
- This container has bash, git, vim, tmux, shellcheck, no docker daemon, no iproute2,
  no virsh, no ssh client, no systemd user session. Infra games are converted here and
  verified by the lint + by the architect/owner on a Linux host.

## Backlog (not this sprint)

Progress file under XDG; root `play.sh` launcher; in-shell `hint`/`task` helpers and
custom prompt; real-state validators for the 11 answer-only levels; tiered hints;
README and `docs/plan.md` rewrite; docker-game solutions in CI; vim-game import;
`known_hosts` isolation for ssh-game; pinned images for ssh-game.
