# CLI Academy tests

## 1. Overview

This directory holds the non-interactive test tooling for the games under `games/`.

- **The harness** (`run-level.sh`, `run-game.sh`) plays a level with a scripted player, a
  *solution script*, and reports a verdict. It drives the engine's test mode,
  `./play.sh test <ID> <solution.sh>` (`docs/engine-contract.md` §7). `run-game.sh` runs every
  committed solution of a game, checks that correct solutions pass and deliberately wrong ones
  fail, prints a table, and exits non-zero on any mismatch.
- **The self-test** (`harness-selftest.sh`) checks the harness itself against a synthetic game in
  `tests/fixtures/`, which exercises every verdict.
- **The lint** (`lint-levels.sh`, written by another ticket) checks that every game follows the
  engine contract's layout and coding rules, without running any level.

Nothing in the harness writes inside the repository: each run happens in a private directory
under `/tmp`, which is removed afterwards.

## 2. Quick start

```bash
# every solution of one game (the table ends with RESULT: PASS or RESULT: FAIL)
tests/run-game.sh bash-game
tests/run-game.sh --only 0,boss01 bash-game        # just these levels

# one level with one solution
tests/run-level.sh bash-game 0 tests/solutions/bash-game/0.sh
tests/run-level.sh --verbose --keep git-game 12 tests/solutions/git-game/12.sh

# check a level under a particular git config (see "Environment hook" below)
CLI_ACADEMY_TEST_GITCONFIG=/path/to/gitconfig tests/run-level.sh git-game 12 tests/solutions/git-game/12.sh

# check the harness itself
tests/harness-selftest.sh

# lint the level files of every game
tests/lint-levels.sh --help
```

Until the engine ships `play.sh test` (ticket D-ENGINE), add `--legacy` to `run-level.sh`,
`run-game.sh` and `harness-selftest.sh` (section 7).

## 3. run-level

```
tests/run-level.sh [options] <game> <ID> <solution.sh>
```

| Option | Meaning |
|---|---|
| `--legacy` | Drive today's interactive engine through stdin (section 7). |
| `--timeout <s>` | Integer 1-600; overrides the solution header. |
| `--log <file>` | Write the full engine output, with a header, to `<file>` (parent directories are created). Default: a temp file deleted at exit. |
| `--quiet` | Print only the RESULT line. |
| `--verbose` | Print the engine output even on PASS. |
| `--keep` | Keep the run directory; prints `kept: <dir>` on stderr. |
| `--games-dir <dir>` | Where `<game>/` lives. Default: `<repo>/games`. |
| `--no-msg-check` | Skip the PASS_MSG/FAIL_MSG check. |
| `-h`, `--help` | Print usage and exit 0. |

**Timeout.** `--timeout` if given; otherwise the first line within the solution's first 10 lines
that matches `^# timeout: ([0-9]+)$`; otherwise 30 seconds. A value outside 1-600 is an input error.
The engine runs under `timeout -k 5 <T>`, so a TERM from the timeout still lets the engine's
trap clean up; a process that ignores TERM is killed 5 seconds later.

**Input errors.** An unknown option or the wrong number of arguments prints the usage to stderr
and exits 2 *without* a RESULT line. These input errors print a message to stderr and a RESULT
line with verdict ERROR (`rc=-`, `secs=0`), then exit 2: an unknown game
(`<games-dir>/<game>/play.sh` missing), an ID that does not match `^[a-zA-Z0-9_]+$`, a missing or
unreadable solution file, a bad timeout value, an unreadable `CLI_ACADEMY_TEST_GITCONFIG`.

**Environment hook.** If `CLI_ACADEMY_TEST_GITCONFIG=<file>` is set, the file is copied to the
run's `$HOME/.gitconfig`. It lets someone check a level under a chosen git config, for example one
with `init.defaultBranch = main`.

**The pinned environment, and why.** The engine runs under `env -i` with exactly these variables
and nothing else (no `TMUX`, `GIT_DIR`, `BASH_ENV` or CI variables):

```
PATH=<caller's PATH>
HOME=<run dir>/home                  # empty; plus .gitconfig from CLI_ACADEMY_TEST_GITCONFIG if set
USER=<id -un>    LOGNAME=<id -un>
SHELL=<command -v bash>
TERM=xterm-256color
LANG=C    LC_ALL=C
TMPDIR=<run dir>/tmp
TMUX_TMPDIR=<run dir>/tmux
GIT_CONFIG_NOSYSTEM=1
GIT_TERMINAL_PROMPT=0
GIT_EDITOR=true    EDITOR=true    VISUAL=true
PAGER=cat    GIT_PAGER=cat
```

A solution must give the same result on a developer laptop, in CI and in this container, so
nothing from the caller's environment may leak in. An empty `HOME` means no global git config (no
identity, default branch `master`) and no `~/.tmux.conf`; a fixed locale and `TERM` make output
deterministic; a private `TMPDIR` lets the harness see exactly what a level leaves behind; a
private `TMUX_TMPDIR` keeps tmux servers (and their unix sockets) inside the run directory. The run
directory is `/tmp/cla.XXXXXXXX`, deliberately short because unix socket paths are limited to about
104 bytes.

**Verdicts and exit codes.** The exit code of `run-level.sh` is the verdict code.

| Verdict | Exit | Meaning |
|---|---|---|
| PASS | 0 | Engine exit 0 (level solved), all checks below clean. |
| FAIL | 1 | Engine exit 1 (validator rejected the work), all checks below clean. |
| ERROR | 2 | Input error (above), or the engine exited 2 (usage or setup error). |
| TIMEOUT | 3 | The engine exceeded the timeout (`timeout` exit 124, or 137 after the kill). |
| CRASH | 4 | The engine exited with something other than 0, 1 or 2; or test mode wrote `progress.log`; or it exited 0/1 without printing PASS_MSG/FAIL_MSG. |
| LEAK | 5 | The run left files in its private `TMPDIR`, or a tmux server still running. |

Contract-mode decision order (the first match wins): TIMEOUT, ERROR, CRASH (exit code), CRASH
(`progress.log` changed; the harness compares the `cksum` of `<games-dir>/<game>/progress.log`
before and after), CRASH (missing message), LEAK, then PASS or FAIL. The message check reads
PASS_MSG (after exit 0) or FAIL_MSG (after exit 1) from the level's `level.conf` by evaluating only
its plain assignments (`harness_conf_get` in `tests/lib/harness.sh`; no other command in the file
runs) and looks for it in the engine output; `--no-msg-check` skips it. A leaked tmux server is
killed after it is reported. The note of a non-clean verdict says what was seen, for example
`engine exit 3`, `test mode wrote progress.log`, `engine exited 0 without printing PASS_MSG`,
`left in TMPDIR: tmp.AbC123`, `tmux server tmuxgame_123_456 still running`.

**Cleanup.** Always, including after a TIMEOUT or an interrupt (Ctrl-C, TERM, HUP): the engine is
stopped, every tmux server whose socket is under the run directory is killed, and the run
directory is removed (unless `--keep`).

**Output.** Unless `--quiet`: if the verdict is not PASS, or with `--verbose`, the engine output
is printed first, every line prefixed with `  | `. The last line is always exactly one RESULT line:

```
RESULT <VERDICT> <game> <ID> <solution basename> rc=<rc> secs=<n> mode=<contract|legacy>[ note=<text>]
```

`rc` is the engine's exit code (`-` for input errors), `secs` the wall-clock whole seconds.

## 4. run-game

```
tests/run-game.sh [--legacy] [--log-dir <dir>] [--only <ID>[,<ID>...]] [--games-dir <dir>] [--solutions-dir <dir>] <game>
```

Defaults: games-dir is `<repo>/games`, solutions-dir is `<repo>/tests/solutions`, log-dir is a new
`/tmp/cla-logs.XXXXXXXX` (created if given but missing). The level IDs are the `LEVEL_ORDER`
tokens of the game's `play.sh`, in that order; `--only` restricts the run to the listed IDs (still
in `LEVEL_ORDER` order) and skips the orphan check. Runs are sequential. Each check runs
`run-level.sh --quiet --log <log-dir>/<file>.log ...`; the log ends with run-level's RESULT line
(prefixed `# `), which carries the note.

For each ID, with D = `<solutions-dir>/<game>`:

- `D/<ID>.sh` missing: row `MISSING`.
- `D/<ID>.xfail` exists but holds only whitespace: row `BADMARK`; the level is not run.
- `D/<ID>.xfail` exists: `<ID>.sh` is run expecting a non-PASS (`XFAIL`, good) and a PASS is `XPASS`
  (bad: the level is fixed, remove the marker). `<ID>.wrong.sh`, if present, gets a `SKIP` row.
- Otherwise `<ID>.sh` is run expecting PASS (`ok` or `MISMATCH`), then `<ID>.wrong.sh`, if present,
  expecting exactly FAIL (`ok` or `MISMATCH`; ERROR, TIMEOUT, CRASH and LEAK do not count).
- Without `--only`, every other entry in D is an `ORPHAN` row.

The table (one row per file, printed as soon as it is known):

```
LEVEL        FILE                 EXPECT GOT       SECS  STATUS
0            0.sh                 PASS   PASS         0  ok
0            0.wrong.sh           FAIL   FAIL         0  ok
12           12.sh                XFAIL  FAIL         1  XFAIL
12           12.wrong.sh          -      -            -  SKIP
19           19.sh                -      -            -  MISSING
```

Good statuses are `ok`, `XFAIL` and `SKIP`. Bad statuses are `MISSING`, `BADMARK`, `XPASS`,
`MISMATCH` and `ORPHAN`. For every bad row that has a log, `---- <file>: <STATUS> (log: <path>)`
follows the table, with the last 40 lines of that log. The footer is:

```
SUMMARY <game>: <checks> checks, <ok> ok, <bad> bad (levels=<n>, wrong=<n>, xfail=<n>, skipped=<n>) mode=<contract|legacy>
Logs: <log-dir>
RESULT: PASS    (or RESULT: FAIL)
```

**Exit codes.** 0 when there is no bad row; 1 when at least one row is bad; 2 on a usage error, a
missing `play.sh`, a missing `<solutions-dir>/<game>/`, an empty LEVEL_ORDER, an `--only` ID that
is not in LEVEL_ORDER, or a missing game dependency (`TOOL_DEPENDENCY` in `game.conf`).

## 5. Solution scripts

### Solution-script spec (shared by all games; tests/README.md documents the same text)
- **Location:** `tests/solutions/<game>/<ID>.sh` for every `<ID>` in the game's `LEVEL_ORDER`, using the exact token: `0.sh`, `17.sh`, `boss01.sh`. There are two optional companions: `<ID>.wrong.sh`, a realistic wrong attempt that must FAIL, and `<ID>.xfail`, which marks a known-broken level. Nothing else may live in that directory (the harness reports extra files as ORPHAN), and there are no shared helper files: every script stands alone.
- **How it runs:** the engine sets the level up exactly as for a player (fresh sandbox directory, `setup_sandbox` done), then runs `bash <absolute path of the script> "$TMP_FILE"` with:
  - cwd = the sandbox directory, already populated by `setup_sandbox`;
  - stdin = `/dev/null` and no terminal;
  - a pinned environment:
    - `HOME` is empty: no global git config, so no identity, and git's default branch is `master`; no `~/.tmux.conf`.
    - `LANG=C`, `LC_ALL=C`, `TERM=xterm-256color`.
    - A private `TMPDIR` and `TMUX_TMPDIR`.
    - `GIT_EDITOR=true`, `EDITOR=true`, `VISUAL=true`, `PAGER=cat`, `GIT_PAGER=cat`, `GIT_TERMINAL_PROMPT=0`.
    - Plus whatever `setup_sandbox` exported (tmux-game: `TMUX_SOCKET` and the exported shell function `tmuxa`).
  - The script's own exit status is ignored; the level's validator decides. The default timeout is 30 s.
- **Rules:**
  1. Use cwd-relative paths. Do not use `SANDBOX_DIR`, `LEVEL_DIR`, `GAME_DIR`, `LEVEL_ID`, `TMP_FILE` or `$1`: the interim legacy mode doesn't provide them, and these games don't need them.
  2. Never read, source or copy anything under `games/` or `engine/` at runtime. Solve the task from the sandbox state, as a player would after reading `template.txt`. (You, the author, may of course read the level files to understand the task.)
  3. **Write honest solutions:** `<ID>.sh` does what `template.txt` asks, using the tool or feature the level teaches. Do not game the validator. That rules out:
     - hiding required keywords in comments;
     - hard-coding an answer the task says to compute or look up;
     - `tmux set-buffer` instead of copy mode;
     - git `url.<x>.insteadOf` redirects;
     - hand-editing `.git/` internals to fake state.
  4. **Deterministic and bounded:**
     - no network;
     - no single `sleep` longer than 0.5 s; wait for asynchronous effects with a bounded polling loop (at most 5 s);
     - if a level genuinely needs more than 30 s, put `# timeout: <seconds>` (at most 120) within the first 10 lines.
  5. **Side effects stay in the sandbox:**
     - never `git config --global` or `--system`;
     - never write to `$HOME`;
     - never run `tmux` without `-L "$TMUX_SOCKET"` (or the `tmuxa` helper);
     - never kill processes or servers you didn't start.
  6. **Shape:**
     - line 1 is `#!/usr/bin/env bash`;
     - line 2 is `# <game> level <ID>: <NAME from level.conf>`;
     - then `set -euo pipefail`;
     - the script is clean under `shellcheck -S warning`.

     The last command of a correct solution must succeed: in the legacy mode, a non-zero status kills the old engine (bug B2).
  7. **`<ID>.wrong.sh`:**
     - line 2 is `# <game> level <ID>: <NAME> (WRONG)`;
     - line 3 is `# Mistake: <the realistic mistake and which validator check should reject it>`.

     It must make the validator fail (engine exit 1, verdict FAIL) *for that reason*. Failing setup, timing out, or failing for an unrelated reason doesn't count. Don't write one for a level whose validator cannot catch any realistic mistake; record that level as `validator-weak` in the known-issues file instead.
  8. **`<ID>.xfail`:** create it only when the honest `<ID>.sh` cannot pass because the level itself is broken.
     - It contains exactly one line: `<kind>: <one-line reason> - see tests/known-issues/<game>.md`.
     - It needs a matching entry in `tests/known-issues/<game>.md`.
     - When the marker exists, the harness expects `<ID>.sh` NOT to pass (XFAIL; a pass is XPASS, which fails the run, so the marker gets removed once the level is fixed) and skips `<ID>.wrong.sh`.
     - `<ID>.sh` stays the honest solution, so it turns green once the level is fixed.

### Known-issues entry format (`tests/known-issues/<game>.md`)
~~~
# Known issues: <game>

Found by the solution scripts in tests/solutions/<game>/ (ticket T-SOL-<game>), run in the
harness environment described in tests/README.md. Levels are listed in LEVEL_ORDER order.

## level<ID>: <one-line title>
- Kind: setup-broken | validator-impossible | validator-weak | template-wrong | contract-violation | env-dependent
- Effect: xfail | no .wrong.sh possible | informational
- Evidence:
```text
<exact command you ran>
<verbatim output, at most 15 lines>
```
- Suggested fix (dev team, not applied): <one or two lines>
~~~
Kinds:
- `setup-broken`: `setup_sandbox` fails or builds the wrong state.
- `validator-impossible`: the honest solution cannot satisfy the validator.
- `validator-weak`: the validator accepts wrong work or no work, for example a no-op passes.
- `template-wrong`: the instructions in `template.txt` or `hint.txt` are wrong or not enough to pass.
- `contract-violation`: level code breaks `docs/engine-contract.md` in a way that affects testing.
- `env-dependent`: the outcome depends on the player's environment (git version or config, locale, network).

## 6. Known issues and xfail

Levels that cannot be solved as written, or whose validators are too weak, are recorded as known
issues instead of being fixed by testers. See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for the index, the
entry format and the kinds. A `tests/solutions/<game>/<ID>.xfail` marker points at the entry in
`tests/known-issues/<game>.md`; with the marker present the harness expects `<ID>.sh` not to pass
(`XFAIL`) and a pass (`XPASS`) fails the run, so the marker must be removed once the level is fixed.

## 7. Legacy mode

`--legacy` is a temporary interim mode for `run-level.sh`, `run-game.sh` and `harness-selftest.sh`.
It exists because the engine's test mode (`./play.sh test`) is still being written; it drives
today's interactive engine through stdin instead. It will be removed in sprint 2, once D-ENGINE has
shipped `play.sh test`.

How it works: the repo's `engine/` and the game directory are copied into the run directory (the
copied `progress.log` is deleted), then, from the copied game directory, the harness runs
`printf 'bash %q </dev/null\nexit\nn\n' <solution> | ... ./play.sh replay <ID>` under the same
pinned environment. The old engine launches the level's `TOOL_CMD` (`bash`), which reads the
solution run and `exit` from stdin; the last line answers the "continue?" prompt with `n`.

How it differs from contract mode:

- The verdict is TIMEOUT if `timeout` fired (exit 124 or 137); otherwise PASS if the engine output
  has a line starting with `[PASS] `, else FAIL. It is never ERROR, CRASH or LEAK: a failing level
  and a failing `setup_sandbox` both just look like FAIL, and the old engine skips its cleanup on
  failure (bug B1) so leftovers are expected. Live tmux servers are still killed and mentioned in
  the note.
- The old engine has bugs the contract fixes: a solution whose last command fails kills it before
  validation (bug B2, so a correct solution must end with a successful command), and it does not
  export `SANDBOX_DIR`, `LEVEL_ID`, `GAME_DIR`, `LEVEL_DIR` or `TMP_FILE`, which is why solutions
  must use cwd-relative paths only.
- The PASS_MSG/FAIL_MSG, `progress.log` and leak checks of contract mode do not apply.

## 8. CI

`.github/workflows/ci.yml` (another ticket, T-CI) runs shellcheck, the lint, the harness
self-test, and `run-game.sh` for bash-game, git-game and tmux-game.
