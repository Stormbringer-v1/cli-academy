#!/usr/bin/env bash
# tests/lint-selftest.sh - proves that every rule of tests/lint-levels.sh fires,
# that a clean game passes, and that the lint never executes level code.
#
# Fixtures: tests/fixtures/lint/games/{clean-game,bad-game}.
# Prints "ok <n> - ..." / "not ok <n> - ... (<observed>)" per assertion, then
# "selftest: <passed>/<total> passed". Exits 0 only if every assertion passed.
# Works from any cwd and writes nothing inside the repo.

set -uo pipefail
export LC_ALL=C

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P) || exit 2
LINT=$HERE/lint-levels.sh
GAMES=$HERE/fixtures/lint/games
PROBE=/tmp/cli-academy-lint-fixture-executed

RULE_IDS=(
  G-PLAY-EXEC G-SHEBANG G-SYNTAX G-ORDER-PARSE G-ORDER-DUP G-ORDER-MISSING
  G-DIR-NAME G-DIR-ORPHAN G-COMMON-TOPLEVEL G-COMMON-FORBIDDEN
  L-FILES L-CONF-STMT L-CONF-KEYS L-CONF-RULES
  L-VALIDATE-MISSING L-VALIDATE-EXEC L-VALIDATE-FAILPATH
  L-SBX-TOPLEVEL L-SBX-FORBIDDEN
)

total=0
passed=0

pass() {
  total=$((total + 1))
  passed=$((passed + 1))
  printf 'ok %d - %s\n' "$total" "$1"
}

fail() {
  total=$((total + 1))
  printf 'not ok %d - %s (%s)\n' "$total" "$1" "$2"
}

# expect_rc <description> <expected rc> <actual rc>
expect_rc() {
  if [[ $3 -eq $2 ]]; then pass "$1"; else fail "$1" "exit $3, expected $2"; fi
}

# expect_has <description> <text> <needle>
expect_has() {
  if [[ $2 == *"$3"* ]]; then pass "$1"; else fail "$1" "missing: $3"; fi
}

# 1. the safety probe must not exist before we start
rm -f "$PROBE"

# 2. clean-game passes
clean_out=$("$LINT" --games-dir "$GAMES" clean-game 2>&1)
clean_rc=$?
expect_rc "clean-game exits 0" 0 "$clean_rc"
expect_has "clean-game summary reports 2 levels, 0 findings" "$clean_out" "== clean-game: 2 levels, 0 findings"

# 3. bad-game fails and every rule fires
bad_out=$("$LINT" --games-dir "$GAMES" bad-game 2>&1)
bad_rc=$?
expect_rc "bad-game exits 1" 1 "$bad_rc"
for id in "${RULE_IDS[@]}"; do
  expect_has "bad-game triggers $id" "$bad_out" ": $id: "
done

# contents of directories that are not valid levels are not checked: no finding
# may point at a file inside them (the G-DIR-* findings point at the directory)
if grep -Eq 'levels/level99/[A-Za-z]' <<<"$bad_out"; then
  fail "orphan level99 contents are not checked" "finding inside levels/level99/"
else
  pass "orphan level99 contents are not checked"
fi
if grep -Eq 'levels/boss01/[A-Za-z]' <<<"$bad_out"; then
  fail "badly named boss01 contents are not checked" "finding inside levels/boss01/"
else
  pass "badly named boss01 contents are not checked"
fi

# prefix assignments ("X=1 touch f") are commands, not assignments
expect_has "level.conf prefix-assignment command is reported" "$bad_out" "level.conf:5: L-CONF-STMT: "
expect_has "sandbox.sh prefix-assignment command is reported" "$bad_out" "sandbox.sh:3: L-SBX-TOPLEVEL: "

# 4. nothing was executed
if [[ -e $PROBE ]]; then
  fail "lint did not execute level code" "$PROBE was created"
  rm -f "$PROBE"
else
  pass "lint did not execute level code ($PROBE absent)"
fi

# 5. both games, from another cwd
all_out=$(cd / && "$LINT" --games-dir "$GAMES" 2>&1)
all_rc=$?
expect_rc "all fixture games exit 1 (run from /)" 1 "$all_rc"
expect_has "all fixture games print the clean-game summary" "$all_out" "== clean-game: "
expect_has "all fixture games print the bad-game summary" "$all_out" "== bad-game: "
expect_has "all fixture games print a TOTAL line" "$all_out" "TOTAL: "
expect_has "TOTAL counts one game with findings of two checked" "$all_out" "in 1 of 2 games checked"

# 6. unknown game is a usage error
"$LINT" no-such-game >/dev/null 2>&1
expect_rc "unknown game exits 2" 2 "$?"

# 7. --list-rules
rules_out=$("$LINT" --list-rules 2>&1)
rules_rc=$?
expect_rc "--list-rules exits 0" 0 "$rules_rc"
missing=''
for id in "${RULE_IDS[@]}"; do
  [[ $rules_out == *"$id  "* ]] || missing+=" $id"
done
if [[ -z $missing ]]; then pass "--list-rules prints all ${#RULE_IDS[@]} rule IDs"; else fail "--list-rules prints all rule IDs" "missing:$missing"; fi

# the probe must still be absent after all runs
if [[ -e $PROBE ]]; then
  fail "no level code ran during any run" "$PROBE was created"
  rm -f "$PROBE"
else
  pass "no level code ran during any run"
fi

printf 'selftest: %d/%d passed\n' "$passed" "$total"
[[ $passed -eq $total ]] && exit 0
exit 1
