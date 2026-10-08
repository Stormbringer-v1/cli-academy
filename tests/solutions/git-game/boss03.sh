#!/usr/bin/env bash
# git-game level boss03: BOSS 03: History Rewriting Master
set -euo pipefail

# The sandbox has ten commits on main; "Commit 7" introduces the line "BAD" into file.txt.
# A side branch, clean-fix, holds one clean commit that does not depend on it.

# 1-2. Bisect for the first commit that has "BAD" and record its hash.
first="$(git rev-list --max-parents=0 HEAD)"
git bisect start
git bisect bad HEAD
git bisect good "$first"

# Let git run the test at every step: exit 0 marks the checked out commit good (no BAD line),
# exit 1 marks it bad. Git stops by itself once the culprit is isolated.
git bisect run sh -c '! grep -q "^BAD$" file.txt'

# Read the result from the ref git maintains, not from its (version-dependent) messages.
found="$(git rev-parse refs/bisect/bad)"

echo "$found" > bad_commit.txt
git bisect reset

# 3. Cherry-pick the clean commit from the other branch onto main.
git cherry-pick clean-fix

# 4. Annotated tag.
git tag -a v1.0 -m "Bugfix release"
git log --oneline --graph --all
