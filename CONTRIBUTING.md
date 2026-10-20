# Contributing to CLI Academy

Everything here is bash. The one document you must read before touching the engine or a
level is [docs/engine-contract.md](docs/engine-contract.md); the lint and the test harness
enforce it, and CI runs both.

## Setting up

```bash
git clone https://github.com/Stormbringer-v1/cli-academy.git
cd cli-academy
# shellcheck 0.11.0 is what CI uses: https://github.com/koalaman/shellcheck/releases
tests/lint-levels.sh            # should report 0 findings
tests/harness-selftest.sh       # should report 15/15
tests/run-game.sh bash-game     # should report all checks ok
```

## Adding or changing a level

A level is a directory `games/<game>/levels/level<ID>/` where `<ID>` is the token that
appears in the game's `LEVEL_ORDER` (in `play.sh`): `level7`, `levelboss01`, `levelcheckpoint2`.

| File | Purpose | Rules |
|---|---|---|
| `level.conf` | declarative config | `NAME`, `TIER`, `TOOL_CMD`, `VALIDATION_TYPE`, `PASS_MSG`, `FAIL_MSG`; assignments only, no commands |
| `template.txt` | what the player reads | self-contained instructions; say what, not the exact command, except in beginner levels |
| `hint.txt` | shown by `./play.sh hint <ID>` | the key command or idea, not the full solution |
| `sandbox.sh` | optional | defines `setup_sandbox` and `cleanup_sandbox` only; no top-level statements, no `set -e`, no `cd`, no `mktemp`, no `rm -rf`: the engine owns the sandbox directory |
| `validate.sh` | required for `VALIDATION_TYPE="script"` | executable; observes the result (files, refs, running state), never performs the task; exits 0 on pass, 1 with a one-line reason on fail |

Then:

1. Add the ID to `LEVEL_ORDER` in the game's `play.sh` and bump `TOTAL_LEVELS` in `game.conf`.
2. Write a scripted solution `tests/solutions/<game>/<ID>.sh` and at least one
   `<ID>.wrong.sh` that fails for a realistic reason. The solution-script rules are in
   [tests/README.md](tests/README.md): honest play only, no reading of level files, no
   parsing of human-readable tool output.
3. Run `tests/lint-levels.sh <game>` and `tests/run-game.sh <game>` until both are clean.
4. If a level cannot be fixed in the same change, record it in
   `tests/known-issues/<game>.md` with evidence and add a `tests/solutions/<game>/<ID>.xfail`
   marker. An xfail that starts passing fails the run, so markers never go stale.

## Changing the engine

Engine changes go through [docs/engine-contract.md](docs/engine-contract.md) first: if the
behaviour you want is not in the contract, change the contract in the same pull request and
say why. The engine runs with `set -uo pipefail` and never `-e`; every path it uses is
absolute; cleanup must be idempotent and run from the exit and signal traps.

## Commits and pull requests

- Conventional commits: `fix(git): ...`, `feat(engine): ...`, `test(tmux-game): ...`, `docs: ...`.
- One logical change per commit.
- CI must be green: shellcheck at the contract's levels, the lint, the harness self-test, and
  the bash, git and tmux solution suites.
- Games whose tools are not on the CI runner (docker, ssh, iptables, sysops, systemd, virsh)
  are verified by the lint plus a manual run on a Linux host; say in the PR what you ran.

## Where to start

[docs/IMPROVEMENTS.md](docs/IMPROVEMENTS.md) is the prioritized list of things worth doing.
