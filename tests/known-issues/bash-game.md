# Known issues: bash-game

Found by the solution scripts in tests/solutions/bash-game/ (ticket T-SOL-bash), run in the
harness environment described in tests/README.md. Levels are listed in LEVEL_ORDER order.

Summary: all 41 honest solutions pass and no level needs an `.xfail` marker. The entries below
are weaknesses and traps in validators and hints. Their evidence comes from throwaway probe
scripts (not committed) that write a `solution.sh` the same way the committed solutions do and were
run through the legacy bridge (`play.sh replay <ID>` fed through stdin, pinned environment: empty
HOME, LC_ALL=C, private TMPDIR). Each block shows the probe's `solution.sh`, the command, and its
output with blank lines removed.

## level4: only the positive branch is ever tested
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
# probe solution.sh: read -r n; if [[ $n -gt 0 ]]; then echo positive; fi   (no elif, no else)
$ /tmp/t-sol-bash/verify-legacy.sh bash-game 4 /tmp/t-sol-bash/probes/04-positive-only.sh | grep -v '^$'
[INFO] Replaying Level 4...
Level 4 - If/Then/Else
Create solution.sh that reads one integer and prints:
- positive if > 0
- negative if < 0
- zero if == 0
Validator input: 5
[PASS] Great! Your conditional logic works.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): validate with several inputs (for example 5, -3, 0) instead of the single `TEST_STDIN='5'`, so the negative and zero branches are exercised.

## level6: the validator rejects the idiomatic `read -r name`
- Kind: template-wrong
- Effect: informational
- Evidence:
```text
# probe solution.sh: read -r name; echo "Hello $name"
$ /tmp/t-sol-bash/verify-legacy.sh bash-game 6 /tmp/t-sol-bash/probes/06-read-r.sh | grep -v '^$'
[INFO] Replaying Level 6...
Level 6 - Read Input
Create solution.sh that reads one name and prints:
Hello <name>
Validator input: Robert
Missing required pattern in solution.sh: read[[:space:]]+[A-Za-z_][A-Za-z0-9_]*
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): relax `REQUIRED_PATTERNS` to allow options, for example `read([[:space:]]+-[A-Za-z]+)*[[:space:]]+[A-Za-z_]`. The committed 6.sh uses plain `read name` (no `-r`) to satisfy the current pattern.

## level9: only the `start` branch is ever tested
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
# probe solution.sh: read -r input; case "$input" in start) echo running ;; esac   (no stop, no default)
$ /tmp/t-sol-bash/verify-legacy.sh bash-game 9 /tmp/t-sol-bash/probes/09-start-only.sh | grep -v '^$'
[INFO] Replaying Level 9...
Level 9 - Case Statements
Create solution.sh that reads one word and prints:
running when input is start
stopped when input is stop
unknown otherwise
Validator input: start
[PASS] Excellent! You used case/esac.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): run the script with `start`, `stop` and an unknown word and compare each output.

## levelboss01: only the positive branch is ever tested
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
# probe solution.sh: read -r n; if [[ $n -gt 0 ]]; then echo positive; fi; for ((i = n; i >= 1; i--)); do echo "$i"; done   (no negative/zero handling)
$ /tmp/t-sol-bash/verify-legacy.sh bash-game boss01 /tmp/t-sol-bash/probes/boss01-positive-only.sh | grep -v '^$'
[INFO] Replaying Level boss01...
BOSS 01 - Shell Basics
Create solution.sh that:
1) reads an integer N
2) prints positive/negative/zero
3) prints a countdown from N to 1
Validator input: 3
[PASS] Boss 01 defeated! Beginner tier complete.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): add runs with a negative and a zero input, as for level4.

## level12: the hint's own example fails the exit-code check
- Kind: template-wrong
- Effect: informational
- Evidence:
```text
# probe solution.sh: ls missing-file 2> errors.log   (the example from hint.txt, verbatim)
$ /tmp/t-sol-bash/verify-legacy.sh bash-game 12 /tmp/t-sol-bash/probes/12-hint-verbatim.sh | grep -v '^$'
[INFO] Replaying Level 12...
Level 12 - Stderr Redirection
Create solution.sh that triggers an error and redirects stderr to errors.log.
Unexpected exit code. Expected 0, got 2
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): the failing `ls` makes the script exit 2 while `EXPECTED_EXIT=0`, and FAIL_MSG ("errors.log was not populated") hides the real reason. Either change the hint to `ls missing-file 2> errors.log || true` and mention the exit code in template.txt, or drop the exit-code check for this level. The committed 12.sh uses `|| true`.

## level14: extra non-ERROR lines are accepted
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
# probe solution.sh: grep -v '^$' service.log > errors.txt   (copies the INFO lines too)
$ /tmp/t-sol-bash/verify-legacy.sh bash-game 14 /tmp/t-sol-bash/probes/14-extra-lines.sh | grep -v '^$'
[INFO] Replaying Level 14...
Level 14 - grep Basics
service.log exists.
Create solution.sh that writes only ERROR lines to errors.txt.
[PASS] grep filtering complete.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): the template says "only ERROR lines" but the post-check only counts lines starting with ERROR. Compare errors.txt exactly with `ERROR disk` and `ERROR mem`.

## level17: the descending order is never checked
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
# probe solution.sh: sort words.txt | uniq -c | sort -n > freq.txt   (ascending, the opposite of the task)
$ /tmp/t-sol-bash/verify-legacy.sh bash-game 17 /tmp/t-sol-bash/probes/17-ascending.sh | grep -v '^$'
[INFO] Replaying Level 17...
Level 17 - sort + uniq
words.txt contains duplicate words.
Create solution.sh that writes frequency counts sorted descending to freq.txt.
[PASS] Frequency report generated.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): check that the first line of freq.txt contains `3 apple`, or compare the whole file after normalising the `uniq -c` padding.

## level20: required patterns also match comments (affects every level)
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
# probe solution.sh: a comment "# greet() is not needed" followed by echo "hello devops" (no function exists)
$ /tmp/t-sol-bash/verify-legacy.sh bash-game 20 /tmp/t-sol-bash/probes/20-comment-only.sh | grep -v '^$'
[INFO] Replaying Level 20...
Level 20 - Functions
Create solution.sh with a function named greet that prints:
hello devops
[PASS] Functions unlocked.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): `validate_solution_level` in games/bash-game/validate_solution.sh runs `grep -Eq` over the raw file, so a keyword in a comment or string satisfies any `REQUIRED_PATTERNS` entry. It affects every level that relies on a pattern (all of them), not just level20. Strip comments before matching, for example `sed 's/^[[:space:]]*#.*//'`, or better check behaviour (call the function, inspect the trap with `trap -p`).

## level27: the `trap` requirement is satisfied by the file name itself
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
# probe solution.sh: touch /tmp/bashgame_trap_file; rm -f /tmp/bashgame_trap_file; echo cleaned   (no trap at all)
$ /tmp/t-sol-bash/verify-legacy.sh bash-game 27 /tmp/t-sol-bash/probes/27-no-trap.sh | grep -v '^$'
[INFO] Replaying Level 27...
Level 27 - Traps
Create solution.sh that creates /tmp/bashgame_trap_file, sets a trap on EXIT to remove it,
prints cleaned, and exits.
[PASS] Trap cleanup works.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): `REQUIRED_PATTERNS=(trap)` matches the substring in `bashgame_trap_file`, so a script without any trap passes. Require `trap[[:space:]]+.*EXIT` or use a marker file name that does not contain "trap".

## level27: fixed path in /tmp breaks parallel runs and survives a killed run
- Kind: env-dependent
- Effect: informational
- Evidence:
```text
$ grep -n bashgame_trap_file games/bash-game/levels/level27/validate.sh games/bash-game/levels/level27/hint.txt
games/bash-game/levels/level27/validate.sh:11:POST_CHECK_CMD='[[ ! -e /tmp/bashgame_trap_file ]]'
games/bash-game/levels/level27/hint.txt:1:trap 'rm -f /tmp/bashgame_trap_file' EXIT
```
- Suggested fix (dev team, not applied): the template, hint and `POST_CHECK_CMD` all hard-code `/tmp/bashgame_trap_file`. Two concurrent runs (CI matrix, `run-game.sh` in parallel) share it, and a stale file from a killed run makes every later run fail. Use a path under `$SANDBOX_DIR`, or export it from `setup_sandbox`. This is the only fixed path in the level files (validate_solution.sh also writes under /tmp, but through unique `mktemp` names). The committed 27.sh and 27.wrong.sh leave nothing behind when run alone.

## level35: the hint's find command produces output the validator rejects
- Kind: template-wrong
- Effect: informational
- Evidence:
```text
# the hint is: find logs -name '*.log' -exec grep 'ERROR' {} + > errors.txt   (tests/solutions/bash-game/35.wrong.sh uses it verbatim)
$ cd /tmp/t-sol-bash/l35 && find logs -name '*.log' -exec grep 'ERROR' {} +
logs/b.log:ERROR two
logs/a.log:ERROR one
$ /tmp/t-sol-bash/verify-legacy.sh bash-game 35 tests/solutions/bash-game/35.wrong.sh | grep -v '^$'
[INFO] Replaying Level 35...
Level 35 - find + exec
logs/ contains multiple .log files.
Create solution.sh that finds all .log files and writes ERROR lines to errors.txt using find -exec.
Post-check command failed.
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): with two files grep prefixes every line with its file name, so no line starts with `ERROR` and the post-check (`grep -c '^ERROR' errors.txt` -ge 2) fails. Change the hint to `grep -h 'ERROR'` (the committed 35.sh uses it) or make the post-check accept `file:ERROR` lines.
