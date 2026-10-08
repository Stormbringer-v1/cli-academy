#!/usr/bin/env bash
# harness-selftest.sh [--legacy] - check run-level.sh and run-game.sh against the
# synthetic fixture game in tests/fixtures/ (every verdict is exercised).
# Prints one "ok <n> - ..." / "not ok <n> - ..." line per assertion, then a
# summary line, and exits 0 only if every assertion passed.
set -uo pipefail
export LC_ALL=C

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib/harness.sh
source "$SELF_DIR/lib/harness.sh"
REPO_ROOT="$(harness_repo_root)"
RUN_LEVEL="$REPO_ROOT/tests/run-level.sh"
RUN_GAME="$REPO_ROOT/tests/run-game.sh"
GAMES="$REPO_ROOT/tests/fixtures/games"
SOLS="$REPO_ROOT/tests/fixtures/solutions"
FIX="harness-fixture"

usage() {
  printf 'Usage: tests/harness-selftest.sh [--legacy]\n'
}

LEG=()
MODE="contract"
case ${1:-} in
  "") ;;
  --legacy)
    LEG=(--legacy)
    MODE="legacy"
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
if (( $# > 1 )); then
  usage >&2
  exit 2
fi

WORK="$(mktemp -d "${TMPDIR:-/tmp}/cla-selftest.XXXXXX")" || {
  echo "harness-selftest: cannot create a work directory" >&2
  exit 2
}
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

total=0
passed=0

report() { # <0|1> <description> <observed>
  total=$((total + 1))
  if [[ $1 -eq 0 ]]; then
    passed=$((passed + 1))
    printf 'ok %d - %s\n' "$total" "$2"
  else
    printf 'not ok %d - %s (%s)\n' "$total" "$2" "$3"
  fi
}

OUT=""
RC=0
run_capture() { # command...  -> OUT (stdout+stderr), RC
  OUT="$("$@" 2>&1)"
  RC=$?
}

result_of() { # last RESULT line of OUT
  printf '%s\n' "$OUT" | grep '^RESULT ' | tail -n 1
}

table_of() { # the table part of a run-game OUT, on one line
  printf '%s\n' "$OUT" | awk '/^(----|SUMMARY)/{exit} {printf "%s%s", sep, $0; sep=" | "}'
}

has_row() { # extended regex, anchored by the caller
  printf '%s\n' "$OUT" | grep -Eq -- "$1"
}

list_run_dirs() {
  local d
  shopt -s nullglob
  for d in /tmp/cla.*; do
    printf '%s\n' "$d"
  done | sort
  shopt -u nullglob
}

level_test() { # <n-desc> <level> <solution file> <expected rc contract> <expected rc legacy>
  local desc=$1 level=$2 file=$3 want
  if [[ $MODE == legacy ]]; then want=$5; else want=$4; fi
  run_capture "$RUN_LEVEL" "${LEG[@]}" --games-dir "$GAMES" "$FIX" "$level" "$SOLS/$FIX/$file"
  if [[ $RC -eq $want ]]; then
    report 0 "$desc" ""
  else
    report 1 "$desc" "expected exit $want, got $RC; $(result_of)"
  fi
}

before_dirs="$(list_run_dirs)"

# 1-7: run-level verdicts
level_test "run-level: correct solution passes" pass pass.sh 0 0
level_test "run-level: wrong solution fails" pass pass.wrong.sh 1 1
level_test "run-level: broken level (xfail fixture) fails" xfail xfail.sh 1 1
level_test "run-level: endless solution times out (--timeout from header)" slow slow.sh 3 3
level_test "run-level: file left in TMPDIR is reported (contract: LEAK; legacy: no leak check)" leak leak.sh 5 0
level_test "run-level: failing setup_sandbox (contract: ERROR; legacy: engine dies, FAIL)" setupfail setupfail.sh 2 1
level_test "run-level: solution exit status is ignored (contract: PASS; legacy: old engine bug B2)" exitcode exitcode.sh 0 1

# 8: usage error
run_capture "$RUN_LEVEL"
if [[ $RC -eq 2 ]] && ! has_row '^RESULT '; then
  report 0 "run-level: no arguments exits 2 with usage and no RESULT line" ""
else
  report 1 "run-level: no arguments exits 2 with usage and no RESULT line" "got exit $RC; $(result_of)"
fi

# 9: missing solution file
run_capture "$RUN_LEVEL" "${LEG[@]}" --games-dir "$GAMES" "$FIX" pass /nonexistent/x.sh
if [[ $RC -eq 2 ]] && has_row '^RESULT ERROR '; then
  report 0 "run-level: missing solution file exits 2 with a RESULT ERROR line" ""
else
  report 1 "run-level: missing solution file exits 2 with a RESULT ERROR line" "got exit $RC; $(result_of)"
fi

# 10: run-game --only pass,xfail
run_capture "$RUN_GAME" "${LEG[@]}" --games-dir "$GAMES" --solutions-dir "$SOLS" --log-dir "$WORK/logs10" --only pass,xfail "$FIX"
if [[ $RC -eq 0 ]] &&
  has_row '^pass +pass\.wrong\.sh +FAIL +FAIL +[0-9]+ +ok$' &&
  has_row '^xfail +xfail\.sh +XFAIL +FAIL +[0-9]+ +XFAIL$'; then
  report 0 "run-game --only pass,xfail: exits 0 with the wrong-solution row ok and the xfail row XFAIL" ""
else
  report 1 "run-game --only pass,xfail: exits 0 with the wrong-solution row ok and the xfail row XFAIL" "exit $RC; $(table_of)"
fi

# 11: run-game, every level
run_capture "$RUN_GAME" "${LEG[@]}" --games-dir "$GAMES" --solutions-dir "$SOLS" --log-dir "$WORK/logs11" "$FIX"
rc11=$RC
ok11=1
if [[ $rc11 -ne 1 ]]; then ok11=0; fi
has_row '^slow +slow\.sh +PASS +TIMEOUT +[0-9]+ +MISMATCH$' || ok11=0
has_row '^nosolution +nosolution\.sh +- +- +- +MISSING$' || ok11=0
if [[ $MODE == legacy ]]; then
  has_row '^leak +leak\.sh +PASS +PASS +[0-9]+ +ok$' || ok11=0
  has_row '^setupfail +setupfail\.sh +PASS +FAIL +[0-9]+ +MISMATCH$' || ok11=0
  has_row '^exitcode +exitcode\.sh +PASS +FAIL +[0-9]+ +MISMATCH$' || ok11=0
else
  has_row '^leak +leak\.sh +PASS +LEAK +[0-9]+ +MISMATCH$' || ok11=0
  has_row '^setupfail +setupfail\.sh +PASS +ERROR +[0-9]+ +MISMATCH$' || ok11=0
  has_row '^exitcode +exitcode\.sh +PASS +PASS +[0-9]+ +ok$' || ok11=0
fi
if [[ $ok11 -eq 1 ]]; then
  report 0 "run-game (all levels): exits 1 with the expected TIMEOUT/LEAK/ERROR/MISSING rows" ""
else
  report 1 "run-game (all levels): exits 1 with the expected TIMEOUT/LEAK/ERROR/MISSING rows" "exit $rc11; $(table_of)"
fi

# 12: a marker on a level that passes is XPASS
cp -R "$SOLS" "$WORK/sols12"
printf 'validator-impossible: pretend the level is broken - see tests/known-issues/x.md\n' >"$WORK/sols12/$FIX/pass.xfail"
run_capture "$RUN_GAME" "${LEG[@]}" --games-dir "$GAMES" --solutions-dir "$WORK/sols12" --log-dir "$WORK/logs12" --only pass "$FIX"
if [[ $RC -eq 1 ]] && has_row ' XPASS$'; then
  report 0 "run-game: an .xfail marker on a passing level is XPASS and fails the run" ""
else
  report 1 "run-game: an .xfail marker on a passing level is XPASS and fails the run" "exit $RC; $(table_of)"
fi

# 13: an empty marker is BADMARK
cp -R "$SOLS" "$WORK/sols13"
: >"$WORK/sols13/$FIX/pass.xfail"
run_capture "$RUN_GAME" "${LEG[@]}" --games-dir "$GAMES" --solutions-dir "$WORK/sols13" --log-dir "$WORK/logs13" --only pass "$FIX"
if [[ $RC -eq 1 ]] && has_row ' BADMARK$'; then
  report 0 "run-game: an empty .xfail marker is BADMARK and fails the run" ""
else
  report 1 "run-game: an empty .xfail marker is BADMARK and fails the run" "exit $RC; $(table_of)"
fi

# 14: stray files are ORPHAN
cp -R "$SOLS" "$WORK/sols14"
printf '#!/usr/bin/env bash\n' >"$WORK/sols14/$FIX/bogus.sh"
run_capture "$RUN_GAME" "${LEG[@]}" --games-dir "$GAMES" --solutions-dir "$WORK/sols14" --log-dir "$WORK/logs14" "$FIX"
if has_row ' ORPHAN$'; then
  report 0 "run-game: a stray file in the solutions directory is reported as ORPHAN" ""
else
  report 1 "run-game: a stray file in the solutions directory is reported as ORPHAN" "exit $RC; $(table_of)"
fi

# 15: nothing left behind
after_dirs="$(list_run_dirs)"
leftover="$(comm -13 <(printf '%s\n' "$before_dirs") <(printf '%s\n' "$after_dirs") | tr '\n' ' ')"
if [[ -z ${leftover// /} ]]; then
  report 0 "no /tmp/cla.* run directory left behind" ""
else
  report 1 "no /tmp/cla.* run directory left behind" "left: $leftover"
fi

printf 'selftest: %d/%d passed (mode=%s)\n' "$passed" "$total" "$MODE"
if (( passed == total )); then exit 0; fi
exit 1
