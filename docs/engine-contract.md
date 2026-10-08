# CLI Academy Engine Contract (v2)

**Status:** adopted 2026-10-08 by the lead architect. Supersedes the "Engine API"
and "Level Configuration Format" parts of `docs/plan.md` §4 where they differ.
Every change to `engine/` and every level must follow this document.

## 1. Level layout

```
games/<game>/
├── play.sh                 # defines LEVEL_ORDER, checks deps, sources engine, calls start_game "$@"
├── game.conf               # metadata (not sourced by the engine yet)
├── <game>_common.sh        # optional helpers, sourced by sandbox.sh files
├── validate_<game>_state.sh# optional helpers, sourced by validate.sh files
└── levels/
    └── level<ID>/
        ├── level.conf      # declarative config (sourced by the engine)
        ├── template.txt    # shown to the player before the tool starts
        ├── hint.txt        # shown by ./play.sh hint <ID>
        ├── sandbox.sh      # optional: defines setup_sandbox / cleanup_sandbox
        └── validate.sh     # required when VALIDATION_TYPE="script"
```

- `<ID>` is any token in `LEVEL_ORDER` matching `^[a-zA-Z0-9_]+$`.
- The directory is **always** `levels/level<ID>`: `level7`, `levelboss01`,
  `levelcheckpoint1`, `levelboss_final`. No other form is resolved.
- `LEVEL_ORDER` must list exactly the set of existing level directories, in play order.

## 2. Working directory and sandbox (engine-owned)

For every level the engine, in this order:

1. Creates `SANDBOX_DIR="$(mktemp -d)"` and `cd`s into it.
2. Exports `SANDBOX_DIR`, `LEVEL_ID`, `GAME_DIR`, `LEVEL_DIR` (absolute path of the level directory).
3. Creates `TMP_FILE` from `template.txt` (empty file if no template) and exports it.
4. Sources `sandbox.sh` if present and calls `setup_sandbox` if defined.
5. Runs the tool (`TOOL_CMD`, or the solution script in test mode).
6. Validates.
7. Calls `cleanup_sandbox` if defined, returns to the original directory, removes
   `SANDBOX_DIR` and `TMP_FILE`.

Rules for `sandbox.sh`:

- MUST NOT create its own temp directory, `cd`, `rm -rf`, call `trap`, or `exit`.
- MUST NOT execute statements at top level other than `source` of the game's common
  files and plain variable assignments. All work goes in `setup_sandbox` / `cleanup_sandbox`.
  In particular **no top-level `set -e` / `set -euo pipefail`**: these files are sourced
  by the engine and would switch errexit back on inside it (verified 2026-10-08). The
  same rule applies to `games/<game>/*_common.sh` and `validate_<game>_state.sh` when
  they are sourced by `sandbox.sh`.
- `*_common.sh` helpers MUST NOT `exit`, delete `SANDBOX_DIR`, or `cd`.
- `setup_sandbox` populates the current directory (which is `SANDBOX_DIR`) and may
  export additional variables for `validate.sh`.
- `cleanup_sandbox` releases external resources only (containers, namespaces, tmux
  servers, background processes, units). Files under `SANDBOX_DIR` are the engine's job.
- `NEEDS_DIR` is deprecated and ignored (behaviour is always "true"). The engine
  tolerates it in `level.conf`; new levels must not set it.

The engine installs a `trap` on `EXIT`, `INT` and `TERM` that runs the current
level's `cleanup_sandbox` (if defined), returns to the original directory and deletes
`SANDBOX_DIR` and `TMP_FILE`. Cleanup is idempotent and runs at most once per level.

Defensive measures the engine takes around level code:

- It saves shell options before sourcing `sandbox.sh` and before calling `setup_sandbox`
  / `cleanup_sandbox`, and restores them afterwards (`opts="$(set +o)"; …; eval "$opts"`).
- It detects a failing command inside `setup_sandbox` (`set -E` plus an `ERR` trap that
  records the failure without aborting) and treats it as a setup error (§3, exit 2).
- It `cd`s back to `SANDBOX_DIR` explicitly after `setup_sandbox` and again before
  validation, so a stray `cd` in level code cannot change what the tool or validator sees.
- `SANDBOX_DIR` and `TMP_FILE` are created with plain `mktemp -d` / `mktemp` so they
  honour `TMPDIR` (the test harness pins it per run).

## 3. Error handling

- `engine/*.sh` and every `play.sh` run with `set -uo pipefail` and **not** `-e`.
  Rationale: `-e` turned a failed validator and a non-zero exit of the player's shell
  into silent crashes (verified 2026-10-08). Failures are handled explicitly.
- The exit status of the player's tool is captured and never used for flow control.
- Validators are separate processes and may use `set -e`. Exit 0 = pass, anything else = fail.
  On failure a validator prints a one-line reason to stdout.
- Never write `local x="$(cmd)"`: declare and assign on separate lines so a failing
  `cmd` is visible.
- A missing level directory, unreadable `level.conf` or failing `setup_sandbox` is a
  setup error: the engine prints a clear message, runs cleanup and exits 2. It never
  falls back to a default tool.

## 4. Paths

- `GAME_DIR` is the directory of the executing `play.sh`, derived from `$0`.
- `LEVELS_DIR="$GAME_DIR/levels"`, `PROGRESS_FILE="$GAME_DIR/progress.log"`
  (the progress location may move to XDG in a later sprint).
- Every path the engine and `ui.sh` use is absolute. `play.sh` works from any cwd.
- Game `sandbox.sh` files MUST NOT use fixed paths such as `/tmp/submod`; derive paths
  from `SANDBOX_DIR`.

## 5. Progress

- One line per completed level: `level<ID>=completed`.
- Lookups match whole lines (`grep -qxF`), never substrings.
- Pre-release: a progress reset caused by this contract is acceptable.

## 6. Command line

| Command | Behaviour |
|---|---|
| `./play.sh` | Play from the first incomplete level in `LEVEL_ORDER`. |
| `./play.sh reset` | Delete progress. |
| `./play.sh replay <ID>` | Play one level, do not continue afterwards. |
| `./play.sh hint <ID>` | Print `hint.txt`. |
| `./play.sh status` | List levels with a completion mark and show `ui_progress`. |
| `./play.sh help` | Usage. Unknown commands print usage and exit 2. |
| `./play.sh test <ID> <solution.sh>` | Test mode, see §7. |

- The continue prompt defaults to **yes**: `(Y/n)`; empty input continues; `Ctrl-D`
  exits cleanly through the trap.
- Before each level the engine prints `ui_level_header "$ID" "$NAME" "$TIER"` and then
  `template.txt`. `ui_progress` is shown on start and by `status`.

## 7. Test mode

`./play.sh test <ID> <solution.sh>` sets the level up exactly as in play (§2 steps 1–4),
then instead of launching the tool runs:

```
bash "<solution.sh>" "$TMP_FILE"
```

with cwd `SANDBOX_DIR` and the same exported environment the player would have
(including anything `setup_sandbox` exported). It then validates and cleans up.

- Exit **0** pass, **1** fail, **2** usage or setup error.
- Never writes progress, never prompts. Prints `PASS_MSG`/`FAIL_MSG` and the validator's output.
- The solution script's own exit status is ignored, like the player's shell.

## 8. Validation

Types are unchanged: `content_check`, `file_exists`, `diff_check`, `command_check`,
`script`. `script` runs `bash "$LEVEL_DIR/$VALIDATION_SCRIPT" "$TMP_FILE"` with cwd
`SANDBOX_DIR` and the exported environment. Wherever a task has observable state
(a running container, an iptables rule, a unit, a process), the validator checks that
state, not only `answer.txt`.

## 9. Code standards

- shellcheck: `engine/` and `games/*/*.sh` clean at `-S warning`; level scripts clean
  at `-S error` (warning is the goal).
- Every script has a shebang; every `play.sh` and `validate.sh` is executable (mode 755).
- git-based sandboxes set the initial branch explicitly (`git symbolic-ref HEAD refs/heads/main`
  right after `git init -q`) and configure a local identity; they never rely on the player's
  global git config.
- Validators observe state; they never perform the task themselves.
- Prefer POSIX forms over GNU-only flags (macOS support).
- Conventional commits: `type(scope): subject`, e.g. `fix(engine): survive non-zero shell exit`.
- Never modify files in the player's home directory from `engine/` code.
