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

Added after the testing lead's review (2026-10-08):

| Ticket | Scope | Fixes | Depends on |
|---|---|---|---|
| D-STRIP-SET | Remove top-level `set -euo pipefail` (and any other top-level statement) from every `sandbox.sh` and `*_common.sh` / `validate_*_state.sh` that is sourced by sandboxes in bash-game, tmux-game and docker-game; `docker_common.sh` cleanup must stop deleting `SANDBOX_DIR`. | re-entry of B1/B2 via sourced files | contract only |
| D-FIX-git | `chmod +x` all 38 `validate.sh`; after every `git init -q` run `git symbolic-ref HEAD refs/heads/main` and set a local identity (12 levels fail with `pathspec 'main'` on a default git); level29: no fixed `/tmp/submod`, no `file://` submodule refusal; level30: no `cd` in setup; level19: no network fetch; validators of 13, 15, 16, 18 must observe, not perform, the task. Input: `tests/known-issues/git-game.md` from T-SOL-git. | git-game playability | T-SOL-git findings |

Every D-CONVERT-* ticket additionally: `chmod +x levels/*/validate.sh`; remove top-level
`set` lines from `sandbox.sh`; `*_common.sh` cleanup helpers must not delete `SANDBOX_DIR`,
`cd`, or `exit` (ssh_common.sh currently calls `exit 1` in helpers).

bash-game and tmux-game otherwise already set `NEEDS_DIR="true"` and do not manage
directories themselves.

## Testing tickets (wave 1)

| Ticket | Scope | Depends on |
|---|---|---|
| T-LINT | `tests/lint-levels.sh`: for every game, the 5 level files exist (validate.sh when type=script), `LEVEL_ORDER` == level dirs, naming per contract §1, `sandbox.sh` has no top-level statements beyond `source`/assignments, `validate.sh` has a failure path, shebangs, exec bits. Exit non-zero on any finding; readable report. | — |
| T-CI | `.github/workflows/ci.yml`: shellcheck per contract §9, `tests/lint-levels.sh`, and the harness for bash/git/tmux on `ubuntu-latest` (tmux installed via apt). | T-LINT, T-HARNESS |
| T-HARNESS | `tests/run-level.sh <game> <ID> <solution>` wrapping `play.sh test`; `tests/run-game.sh <game>` runs every `tests/solutions/<game>/<ID>.sh` and, if present, `<ID>.wrong.sh` (must fail); prints a pass/fail table and exits non-zero on any mismatch. | contract §7 (engine lands in D-ENGINE) |
| T-SOL-bash | `tests/solutions/bash-game/<ID>.sh` for all 41 levels + a `.wrong.sh` for at least 10. | T-HARNESS spec |
| T-SOL-git | Same for git-game (39). | T-HARNESS spec |
| T-SOL-tmux | Same for tmux-game (30). | T-HARNESS spec |

## Architect decisions (2026-10-08, from the testing lead's review)

1. Top-level `set` in sourced level files is a contract violation: lint flags it (T-LINT), D-STRIP-SET and the D-CONVERT tickets remove it, and D-ENGINE saves/restores shell options as a second safeguard.
2. The harness runs the engine in a pinned environment: empty `HOME`, `GIT_CONFIG_NOSYSTEM=1`, `LC_ALL=C`, `TERM=xterm-256color`, per-run `TMPDIR`/`TMUX_TMPDIR`, override hook `CLI_ACADEMY_TEST_GITCONFIG`. The resulting git `main`-branch failures are real player bugs and go to D-FIX-git, not into the harness.
3. xfail markers (`tests/solutions/<game>/<ID>.xfail`) are allowed; XPASS fails the run. Acceptance #3 reads: `run-game.sh` exits 0 and every xfail points to a dev ticket.
4. Known issues live in `tests/known-issues/<game>.md` with `tests/KNOWN_ISSUES.md` as index.
5. `--legacy` stdin mode is accepted for this sprint only and is deleted in sprint 2.
6. LEAK and CRASH verdicts are in.
7. T-CI is dispatched after T-HARNESS and T-LINT merge, and merged once it is green for bash and tmux (after D-ENGINE, D-STRIP-SET, D-FIX-git exec bits).
8. CI pins shellcheck v0.11.0.
9. Solutions are honest: no reading level files at runtime, no gaming validators; tmux attach levels may use `script(1)`.
10. Worker commits use the repository's configured git identity (not the owner's email).

## Architect decisions (2026-10-08, from the development lead's review)

1. sysops levels 19, 29, 34 are dropped from `LEVEL_ORDER`; the game has 36 levels.
2. D-STRIP-SET is implemented as the dev lead's **D-LEGACY** ticket: strip top-level `set` from bash/tmux/docker sandboxes and `tmux_common.sh`/`docker_common.sh`, docker cleanup stops deleting `SANDBOX_DIR`, empty-prefix guards for docker and virsh cleanup helpers, `chmod +x` the 38 git validators, fix git `TOTAL_LEVELS`.
3. In-scope bug fixes ride the conversions: the `grep -E '\d'` validators in sysops (1, 2, 3, 15, 18, 20, 21) and systemd (2, 5, 6, 12); ssh container names (`cliacademy_ssh_l<ID>`, network `cliacademy_ssh_net`, prefix `cliacademy_ssh_`, boss ports 22291/22292, no touching the player's real `~/.ssh` keys, no `local PATH`); virsh cleanup prefixes for boss01/boss02/level24; sysops cleanup kills process groups, not only direct children; iptables level 29 `--ctstate`.
4. Engine behaviours are pinned in contract §10. Two dev-lead proposals were **not** adopted: the engine does re-`cd` to `SANDBOX_DIR` after setup, and setup failures are detected with an ERR trap (both from the testing lead's review).
5. `play.sh` dependency failures exit 2.
6. `NEEDS_DIR` is removed from ssh-game `level.conf` files only; the lint ignores it this sprint (no rule, no warning line); legacy games drop it in sprint 2.
7. Merge order: D-ENGINE first (conversions against the old engine would write into the player's cwd), then D-CONVERT-* in any order, D-LEGACY any time, then T-* branches, T-CI last.
8. Worker commits carry a `Co-Authored-By: Claude <model> <noreply@anthropic.com>` trailer naming either the architect's or the worker's model; both are accepted, and no branch is re-authored for trailer wording.
9. New ticket **D-FIX-tmux** (from T-SOL-tmux): `tmux_window_option_equals` in `validate_tmux_state.sh` calls `show-window-options -qv`, which tmux 3.4 rejects, so level 17 can never pass (fix: `tmuxa show-options -wqv -t "$1" "$2"`); session checks use `has-session -t name`, which prefix-matches (fix: `-t "=name"`). Input: `tests/known-issues/tmux-game.md`.
10. Lint hardening accepted: the level.conf / sandbox.sh evaluator uses a quote-aware statement scanner so prefix-assignment commands (`FOO=1 touch f`) are reported, never executed. `tests/fixtures/**` holds deliberately broken scripts; CI excludes it from shellcheck and lint.

## Acceptance for the sprint

1. `shellcheck -S warning engine/*.sh games/*/*.sh` is clean.
2. `tests/lint-levels.sh` is clean for all games.
3. `tests/run-game.sh bash-game|git-game|tmux-game` all pass in this container and in CI.
4. Manual: in bash-game, fail level 0 → FAIL_MSG + hint tip + continue prompt; `false; exit` → same; Ctrl-C during setup or at the prompt, and SIGTERM, leave no temp dirs or processes.
5. Synthetic two-level game with a sandbox that only populates cwd plays both levels.

## Operating rules

- Every worker works in its own git worktree on its own branch, commits there, never pushes.
- Workers touch only the paths in their ticket. Engine changes go through D-ENGINE only.
- A lead reviews each worker's diff before the architect merges it; nothing merges red.
- Reports to the architect use: **Done / Blocked / Needs decision**, with branch + SHA.
- This container has bash, git, vim, tmux, shellcheck, no docker daemon, no iproute2,
  no virsh, no ssh client, no systemd user session. Infra games are converted here and
  verified by the lint + by the architect/owner on a Linux host.

## Progress log

**2026-10-08, wave 1 merged.** D-ENGINE and all five D-CONVERT tickets, T-LINT, T-HARNESS,
T-SOL-bash and T-SOL-tmux are merged on the sprint branch. Verified on the merged tree:
`shellcheck -S warning engine/*.sh games/*/*.sh` clean; level scripts clean at `-S error`;
`tests/lint-levels.sh` reports 0 findings for iptables, ssh, sysops, systemd and virsh;
`tests/harness-selftest.sh` 15/15 in contract mode; `tests/run-game.sh bash-game` 61/61 and
`tmux-game` 57/57 (level 17 expected xfail); the six interactive pseudo-terminal scenarios
from acceptance #4 pass with zero leaked temp entries or processes. Remaining lint findings
were D-LEGACY's scope plus the git `cd` lines owned by D-FIX-git.

**2026-10-08, sprint complete.** D-LEGACY, D-FIX-tmux, T-SOL-git, D-FIX-git and T-CI merged.
Final acceptance on the sprint head: shellcheck clean at every contract §9 tier (engine and game
roots at warning, level scripts at error, `tests/` at warning with fixtures excluded);
`tests/lint-levels.sh` 0 findings in all 9 games; lint self-test 36/36; harness self-test
15/15 (contract mode); `tests/run-game.sh` bash-game 61/61, git-game 58/58, tmux-game 57/57,
with **no `.xfail` markers left**; a no-op solution fails every level; the six interactive
pseudo-terminal scenarios pass with zero leaked temp entries or processes; `.github/workflows/ci.yml`
validated with actionlint and every step executed locally. All five sprint acceptance items are
met. Pushing remains blocked until the Claude GitHub App has access to the repository.

## Sprint 2 candidates (from this sprint's findings)

- git-game content: level 21 (template rebases a branch the sandbox never creates and the
  command conflicts; any fix changes the player's task), level 14 (template promises a conflict
  the setup never creates), level 31 (any executable hook passes), and the validator-weak levels
  8, 9, 20, 22, 27, 28, 34, boss02 documented in `tests/known-issues/git-game.md`.
- bash-game validator-weak levels 4, 9, boss01, 14, 17, 20, 27 and hint mismatches 6, 12, 35
  (`tests/known-issues/bash-game.md`); tmux-game validator-weak levels 3, 8, 15, 19, 20, 23,
  25, 26, 27 (`tests/known-issues/tmux-game.md`).
- Delete the harness `--legacy` mode and its self-test expectations.
- docker-game solutions as a fourth CI matrix entry (GitHub runners have docker).
- Progress file under XDG; root `play.sh` launcher; in-shell `hint`/`task` helpers and a custom
  prompt; `NEEDS_DIR` removed from the legacy games' `level.conf`.

## Backlog (not this sprint)

Progress file under XDG; root `play.sh` launcher; in-shell `hint`/`task` helpers and
custom prompt; real-state validators for the 11 answer-only levels; tiered hints;
README and `docs/plan.md` rewrite; docker-game solutions in CI; vim-game import;
`known_hosts` isolation for ssh-game; pinned images for ssh-game; sysops level 9 setup
writes `answer.txt` itself (auto-pass); docker prefixes `cliacademy_l24/l25/l26/l32/boss03`
lack a trailing underscore; `validate_solution.sh` uses fixed `/tmp` mktemp templates
(ignores `TMPDIR`); bash-game hints 10/22/32 and tmux level 2 hint rely on GNU `wc` output
(macOS pads); delete the harness `--legacy` mode; lint: flag `rm -f -r` split flags and
command substitutions in top-level assignments other than the `$(cd ... && pwd)` idiom;
per-process isolation for harness self-test check 15.
