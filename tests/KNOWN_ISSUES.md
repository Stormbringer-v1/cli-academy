# Known issues

## Purpose

Some levels cannot be solved as written, and some validators are too weak to catch wrong work.
Testers do not fix those levels. The solution-script tickets record them here instead, as evidence
for the dev team: the harness (see [README.md](README.md)) then keeps running and stays green while
the level is broken, and turns red as soon as the level is fixed.

## Where the entries live

Each game has its own file, written by its solution ticket (T-SOL-bash, T-SOL-git, T-SOL-tmux).
The files may not exist yet if the ticket has not merged.

- [known-issues/bash-game.md](known-issues/bash-game.md)
- [known-issues/git-game.md](known-issues/git-game.md)
- [known-issues/tmux-game.md](known-issues/tmux-game.md)

## How `.xfail` markers point to entries

When the honest solution `tests/solutions/<game>/<ID>.sh` cannot pass because the level itself is
broken, the solution author adds a marker `tests/solutions/<game>/<ID>.xfail`. It holds exactly one
line, `<kind>: <one-line reason> - see tests/known-issues/<game>.md`, and the entry
`## level<ID>: ...` in that file explains the problem. With a marker present,
`tests/run-game.sh` expects `<ID>.sh` NOT to pass (row status `XFAIL`, which is good) and skips
`<ID>.wrong.sh` (row status `SKIP`). `<ID>.sh` stays the honest solution, so it turns green once the
level is fixed.

## What happens next

The dev team turns the entries into fix tickets (the "Suggested fix" line of an entry is the
starting point). When a level is fixed its honest solution passes, the harness reports `XPASS`, and
that fails the run: this forces the marker to be removed in the same change that fixes the level,
and the entry to be deleted or marked fixed. A level whose validator is weak (`validator-weak`) has
no `.wrong.sh`, because there is no realistic wrong attempt the validator would catch.

## Entry format (`tests/known-issues/<game>.md`)
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
