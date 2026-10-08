# Known issues: git-game

Found by the solution scripts in tests/solutions/git-game/ (ticket T-SOL-git), run in the
harness environment described in tests/README.md. Levels are listed in LEVEL_ORDER order.

How to read the evidence: every command was run from the repository root (git 2.43.0, pinned
empty-HOME environment, interim `--legacy` stdin bridge `/tmp/t-sol-git/verify-legacy.sh`). The
bridge prints the engine output and a final `VERDICT:` line. `Kind:` is the problem that blocks
first; `Also:` lists further kinds that apply to the same level. Throwaway helper files, none of them
part of the repository:
- `/tmp/t-sol-git/gitconfig-main`: `[init] defaultBranch = main` (the "branch problem removed" config).
- `/tmp/t-sol-git/gitconfig-ident`: only `[user] name/email`. `gitconfig-ident-file` adds `[protocol "file"] allow = always`.
  `gitconfig-norenames`: `[diff] renames = false`.
- `/tmp/t-sol-git/exp/p.sh`: a probe script written by the `printf` right above its use; probes are not solutions.
- `/tmp/t-sol-git/sim-contract.sh`: sets a level up like docs/engine-contract.md section 2 and 10 (fresh `SANDBOX_DIR`,
  `cd` back to it after setup and again before validation, a failing command inside `setup_sandbox` is a setup error),
  runs the solution, then `validate.sh`.
- `/tmp/t-sol-git/patched/`: a copy of `engine/` + `games/git-game` where every `git init -q` in a `sandbox.sh` is followed by
  `git symbolic-ref HEAD refs/heads/main` and, for level 35 only, `git branch -d feature` became `git branch -D feature`
  (`bash /tmp/t-sol-git/make-patched.sh with-35`).

Flaky validators: many validators run `cmd | grep -q ...` under `set -euo pipefail`. When grep matches early it exits,
`cmd` can die of SIGPIPE, and the pipeline (and the `if` around it) reports failure although the text matched. Each
validator was run 200 times against the honest and the wrong state of its level: only levels 25 and 32 gave unstable
verdicts (see their entries); the wrong scripts were chosen so that no `.wrong.sh` depends on such a race.

Root cause shared by every "default branch" entry: 37 sandboxes run `git init -q` and rely on the player's
global `init.defaultBranch`, so under a fresh git config the branch is `master` and any `git checkout -q main`
in `setup_sandbox` fails. Contract section 9 already prescribes the fix:
`git symbolic-ref HEAD refs/heads/main` right after `git init -q`.

## level3: validator accepts a no-op
- Kind: validator-weak
- Effect: no .wrong.sh possible
- Evidence:
```text
$ printf '#!/usr/bin/env bash\ntrue\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 3 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Commit successful! You've permanently recorded a snapshot of your project.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): `git rev-list -n 1 --all` exits 0 in a repository without commits. Check `git rev-parse --verify -q HEAD >/dev/null` instead.

## level8: validator depends on the English `git status` text; a committed rename is rejected
- Kind: env-dependent
- Also: template-wrong
- Effect: informational
- Evidence:
```text
$ printf '[diff]\n\trenames = false\n' > /tmp/t-sol-git/gitconfig-norenames
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-norenames /tmp/t-sol-git/verify-legacy.sh git-game 8 tests/solutions/git-game/8.sh | tail -n 8
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   new_name.txt
	deleted:    old_name.txt
	deleted:    to_delete.txt

The move was not correctly detected by Git.
VERDICT: FAIL (engine rc=1, timeout=30s)
$ printf '#!/usr/bin/env bash\ngit mv old_name.txt new_name.txt\ngit rm -q to_delete.txt\ngit commit -q -m x\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 8 /tmp/t-sol-git/exp/p.sh | tail -n 3

The renamed file 'new_name.txt' is not staged.
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): replace `git status | grep "renamed: ..."` with `git diff --cached -M --name-status | grep -q '^R'` (verified in a scratch repo: prints `R100 old_name.txt new_name.txt` even with `diff.renames=false`, and does not depend on the locale). Say in template.txt that the change must stay staged (do not commit), or accept a committed rename by also checking HEAD.

## level9: validator accepts a new commit instead of an amend
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\ngit commit --allow-empty -q -m "Initial commit"\ngit log --oneline\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 9 /tmp/t-sol-git/exp/p.sh | tail -n 5
3d430ae Initial commit
12f48fe Initial commti
[PASS] Success! 'git commit --amend' is perfect for fixing small mistakes in your history.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): additionally require that the typo is gone from history (`! git log --format=%s | grep -qx 'Initial commti'`) or that exactly one commit exists (`git rev-list --count HEAD` is 1).

## level10: validator rejects `git checkout -b feature` because the current branch is listed as `* feature`
- Kind: validator-impossible
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\ngit checkout -q -b feature\ngit branch --list\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 10 /tmp/t-sol-git/exp/p.sh | tail -n 4
* feature
  master
Branch 'feature' not found.
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): only the alternative way of creating the branch is rejected (the template's `git branch feature` passes, see 10.sh). Use `git show-ref --verify --quiet refs/heads/feature` instead of grepping `git branch --list`.

## level11: template says the player is on 'main' but a default git creates 'master'
- Kind: template-wrong
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\ntrue\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 11 /tmp/t-sol-git/exp/p.sh | tail -n 3
Type 'exit' when done.
Currently on 'master', not 'develop'.
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): the shared default-branch fix (`git symbolic-ref HEAD refs/heads/main` after `git init -q`) makes the text true.

## level12: setup fails on a default git (branch master)
- Kind: setup-broken
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 12 tests/solutions/git-game/12.sh | tail -n 3
[INFO] Replaying Level 12...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 12 tests/solutions/git-game/12.sh | tail -n 3
[PASS] Fast-forward merge successful!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): `git symbolic-ref HEAD refs/heads/main` right after `git init -q`.

## level13: setup fails on a default git; validator performs the merge itself
- Kind: setup-broken
- Also: contract-violation
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 13 tests/solutions/git-game/13.sh | tail -n 3
[INFO] Replaying Level 13...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 13 tests/solutions/git-game/13.sh | tail -n 3
[PASS] 3-way merge completed successfully!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ printf '#!/usr/bin/env bash\ntrue\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 13 /tmp/t-sol-git/exp/p.sh | tail -n 3
Automatic merge failed; fix conflicts and then commit the result.
Merge failed.
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): branch fix. The suspicion that a no-op passes is NOT confirmed here (the two branches conflict, so the validator's own `git merge feature --no-edit` fails: "Merge failed."), but the validator still mutates the repository and breaks contract section 9. Observe instead: HEAD has two parents (`git rev-list --parents -n 1 HEAD | wc -w` is 3), no `MERGE_HEAD`, no conflict markers in file.txt.

## level14: setup fails on a default git; template promises a conflict that does not exist; validator passes without a merge
- Kind: setup-broken
- Also: template-wrong, validator-weak
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 14 tests/solutions/git-game/14.sh | tail -n 3
[INFO] Replaying Level 14...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 14 tests/solutions/git-game/14.sh | tail -n 3
[PASS] Merge conflict resolved and committed!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ printf '#!/usr/bin/env bash\necho "Hello Universe" > greeting.txt\ngit add greeting.txt\ngit commit -q -m x\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 14 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Merge conflict resolved and committed!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): branch fix. Either start the merge in `setup_sandbox` (`git merge feature || true`) so the conflict the template describes is really there, or add `git merge feature` to the steps. Require a merge commit in the validator (`git rev-list --merges -n 1 HEAD` not empty); today any third commit that contains "Hello Universe" passes (last probe above).

## level15: validator performs the task; no-op passes
- Kind: validator-weak
- Also: contract-violation
- Effect: no .wrong.sh possible
- Evidence:
```text
$ printf '#!/usr/bin/env bash\ntrue\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 15 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Changes stashed successfully! You can now switch branches.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): do not run `git stash` in the validator. Observe: `git stash list | grep -q .` and a clean tree (`git diff --quiet HEAD && git diff --cached --quiet`).

## level16: validator runs `git stash pop` itself, so the honest solution fails and a no-op passes
- Kind: validator-impossible
- Also: validator-weak, contract-violation
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 16 tests/solutions/git-game/16.sh | tail -n 4
Dropped refs/stash@{0} (7f7be91c38ac2639539f8bf9829118881a948c5d)
 M file.txt
Stash pop failed.
VERDICT: FAIL (engine rc=1, timeout=30s)
$ printf '#!/usr/bin/env bash\ntrue\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 16 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Stash applied with pop!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): do not run `git stash pop` in the validator. Observe: `git stash list` is empty and file.txt contains "changes" (`grep -q changes file.txt`).

## level17: setup fails on a default git; validator can never see branching; branch_commits.txt is ignored
- Kind: setup-broken
- Also: validator-impossible, validator-weak, template-wrong
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 17 tests/solutions/git-game/17.sh | tail -n 3
[INFO] Replaying Level 17...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 17 tests/solutions/git-game/17.sh | tail -n 4
* d19cb65 Commit 1
1
Git graph does not show branching.
VERDICT: FAIL (engine rc=1, timeout=30s)
$ printf '#!/usr/bin/env bash\ngit merge feature -m m || { git checkout --theirs file.txt; git add file.txt; git commit -q -m m; }\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 17 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Git graph shows your branching history!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): branch fix. `git log --graph --oneline` (no `--all`) only shows HEAD's history, which is linear, so it never prints `|`; the last probe merges the branches and passes without writing branch_commits.txt. Validate the file content instead of the graph. Decide the expected number: template.txt ("how many commits are on the 'feature' branch") suggests 2, hint.txt ("specific to the feature branch") suggests 1; 17.sh writes 1.

## level18: setup fails on a default git; validator runs `git branch -d feature` itself
- Kind: setup-broken
- Also: validator-impossible, contract-violation
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 18 tests/solutions/git-game/18.sh | tail -n 3
[INFO] Replaying Level 18...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 18 tests/solutions/git-game/18.sh | tail -n 4
Deleted branch feature (was e246821).
* main
Branch deletion failed.
VERDICT: FAIL (engine rc=1, timeout=30s)
$ printf '#!/usr/bin/env bash\ntrue\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 18 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Merged branch deleted cleanly!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): branch fix. Observe instead of acting: `! git show-ref --verify --quiet refs/heads/feature`.

## level19: validator fetches from the network
- Kind: validator-impossible
- Also: env-dependent
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 19 tests/solutions/git-game/19.sh | tail -n 4
fatal: could not read Username for 'https://github.com': terminal prompts disabled
fetch failed (no network / no such repository)
Remote fetch failed.
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): `https://github.com/example/repo.git` does not exist, so `git fetch origin` can never succeed (the validator even adds the remote itself). Create a local bare repository in `setup_sandbox` (a sibling path derived from `SANDBOX_DIR`, removed in `cleanup_sandbox`), use its path in the template, and validate `git remote get-url origin` plus a ref under `refs/remotes/origin/`.

## levelboss02: sandbox never creates 'main'; validator does not check the "main work" line
- Kind: setup-broken
- Also: validator-weak
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game boss02 tests/solutions/git-game/boss02.sh | tail -n 4

Type 'exit' when done.
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game boss02 tests/solutions/git-game/boss02.sh | tail -n 3
[PASS] BOSS 02 DEFEATED! You've mastered branching and merging!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game boss02 /tmp/t-sol-git/exp/boss02c.sh | tail -n 3
[PASS] BOSS 02 DEFEATED! You've mastered branching and merging!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): branch fix (the sandbox commit is made on `master`, template step 4 `git checkout main` fails and validate.sh insists on `main`). The last run resolves the conflict by dropping "main work" and still passes, because `grep -q "main" file.txt` matches the first line "main". Use `grep -qx 'main work' file.txt && grep -qx 'feature work' file.txt`.

## level20: setup fails on a default git; validator passes without a rebase
- Kind: setup-broken
- Also: validator-weak
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 20 tests/solutions/git-game/20.sh | tail -n 3
[INFO] Replaying Level 20...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 20 tests/solutions/git-game/20.sh | tail -n 3
[PASS] Rebase completed! Your commit history is now linear.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ printf '#!/usr/bin/env bash\ngit checkout -q feature\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 20 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Rebase completed! Your commit history is now linear.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): branch fix. `git checkout feature` alone satisfies "on feature with at least 3 commits" (it already has 3). Require `git merge-base --is-ancestor main feature` and no merge commits.

## level21: setup fails on a default git; template command names a branch that does not exist; validator passes without a rebase
- Kind: setup-broken
- Also: template-wrong, validator-weak
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 21 tests/solutions/git-game/21.sh | tail -n 3
[INFO] Replaying Level 21...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ printf '#!/usr/bin/env bash\ngit rebase --onto main old-feature~1 feature\necho rc=$?\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 21 /tmp/t-sol-git/exp/p.sh | tail -n 4
fatal: no such branch/commit 'feature'
rc=128
Rebase --onto may not have completed.
VERDICT: FAIL (engine rc=1, timeout=30s)
$ printf '#!/usr/bin/env bash\ngit branch feature old-feature\ngit rebase --onto main old-feature~1 feature\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 21 /tmp/t-sol-git/exp/p.sh | grep -E '^CONFLICT|^error: could not apply|^VERDICT'
CONFLICT (content): Merge conflict in file.txt
error: could not apply 4c873d1... Old feature 2
VERDICT: FAIL (engine rc=1, timeout=30s)
$ printf '#!/usr/bin/env bash\ngit checkout -q -b feature\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 21 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Rebase --onto completed successfully!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): branch fix, then name the sandbox branch `feature` (or change template, hint and validator to `old-feature`). Even with the branch present, the template command stops on a content conflict (third run above: "Old feature 2" appends after a line that main does not have; 21.sh creates `feature` from `old-feature` and resolves it), so make the moved commits independent. Validate `git merge-base --is-ancestor main feature` and that "Old feature 1" is not in feature's history.

## level22: setup fails on a default git; validator passes without a cherry-pick
- Kind: setup-broken
- Also: validator-weak
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 22 tests/solutions/git-game/22.sh | tail -n 3
[INFO] Replaying Level 22...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 22 tests/solutions/git-game/22.sh | tail -n 3
[PASS] Cherry-pick successful! You brought a commit from another branch.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ printf '#!/usr/bin/env bash\ngit checkout -q feature\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 22 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Cherry-pick successful! You brought a commit from another branch.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): branch fix. Checking out `feature` also puts "cherry-pick me" into file.txt. Require the current branch to be main and `git cherry main feature | grep -q '^-'` (or `git log main --format=%s` containing the commit subject).

## level24: template steps 3 and 4 cannot run after step 1
- Kind: template-wrong
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\ngit reset --soft HEAD~1\ngit reset HEAD file2.txt\ngit reset HEAD~1\ngit reset --hard HEAD~1\ntrue\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 24 /tmp/t-sol-git/exp/p.sh | tail -n 10
Type 'exit' when done.
fatal: ambiguous argument 'HEAD~1': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
fatal: ambiguous argument 'HEAD~1': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
[PASS] Reset successful! You understand the three modes.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): after `git reset --soft HEAD~1` only one commit is left, so `git reset HEAD~1` and `git reset --hard HEAD~1` fail with `fatal: ambiguous argument 'HEAD~1'`, and the level is already satisfied after step 1 (validator wants exactly one commit). Create three commits in `setup_sandbox`, or reorder the steps. 24.sh re-creates "Commit 2" before steps 3 and 4 so that all three reset modes really run.

## level25: nothing to recover; any `reset` passes; the fallback check is flaky
- Kind: setup-broken
- Also: validator-weak, env-dependent
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\ngit reset -q --hard HEAD\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 25 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Reflog worked! You recovered the 'lost' commit.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ printf '#!/usr/bin/env bash\necho second >> file.txt\ngit add file.txt\ngit commit -q -m Second\ngit reset -q --hard HEAD~1\ngit log --oneline\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 25 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Reflog worked! You recovered the 'lost' commit.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ bash -c 'd=$(mktemp -d); export HOME=$d GIT_CONFIG_NOSYSTEM=1; cd $d; git init -q; git config user.name T; git config user.email t@e.x; echo a > f; git add f; git commit -qm A; echo b >> f; git commit -qam B; git reset -q --hard HEAD~1; set -o pipefail; t=0; f=0; for _ in $(seq 300); do if git reflog | grep -q reset; then t=$((t+1)); else f=$((f+1)); fi; done; echo "pipeline true=$t false=$f"; cd /; rm -rf "$d"'
pipeline true=290 false=10
```
- Suggested fix (dev team, not applied): the template says a commit was already lost to a hard reset, but the sandbox holds only "First commit": make the second commit and run `git reset --hard HEAD~1` in `setup_sandbox` (25.sh stages that accident itself). The validator's reflog fallback (`git reflog | grep -q "reset"`) passes without any recovery (probes 1 and 2) and, under `set -o pipefail`, `grep -q` can close the pipe early so `git` dies of SIGPIPE: the last command shows the fallback's pipeline turning false in 10 of 300 repetitions, so even that wrong attempt is occasionally rejected. Drop the fallback and require the commit count and file content; avoid `cmd | grep -q` under pipefail.

## level26: no commit contains "BAD"; validator accepts any 7-character string
- Kind: setup-broken
- Also: validator-weak
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\necho abcdefg > bad_commit.txt\ngit log -p --all | grep -c BAD || true\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 26 /tmp/t-sol-git/exp/p.sh | tail -n 4
0
[PASS] Bisect successful! You found the culprit commit.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): the template asks to bisect for "BAD" but no commit adds it (the probe prints `0` occurrences), so bisect can only blame HEAD, which 26.sh reports. Add "BAD" in one commit (for example commit 3) in `setup_sandbox` and compare bad_commit.txt with that commit's hash (prefix match, 7+ characters).

## level27: validator accepts a lightweight tag
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\ngit tag v1.0\ngit cat-file -t v1.0\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 27 /tmp/t-sol-git/exp/p.sh | tail -n 4
commit
[PASS] Tag created! You tagged a specific point in history.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): the template asks for an annotated tag but `git tag --list | grep -q "^v1.0$"` accepts both. Also require `[[ $(git cat-file -t v1.0) == tag ]]`.

## level28: the answer can be guessed without running git blame
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\necho Player > author.txt\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 28 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Blame successful! You found the author.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): all commits are by the configured identity "Player", which is also the name the validator looks for. Commit line 2 as another author in `setup_sandbox` (`git commit --author=...`) and check for exactly that name.

## level29: setup commits without identity in a fixed /tmp/submod; submodule add of a local path is refused
- Kind: setup-broken
- Also: env-dependent, contract-violation
- Effect: xfail
- Evidence:
```text
$ rm -rf /tmp/submod
$ /tmp/t-sol-git/verify-legacy.sh git-game 29 tests/solutions/git-game/29.sh | grep -E '^fatal|^VERDICT'
fatal: unable to auto-detect email address (got 'root@vm.(none)')
VERDICT: FAIL (engine rc=128, timeout=30s)
$ rm -rf /tmp/submod
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-ident /tmp/t-sol-git/verify-legacy.sh git-game 29 tests/solutions/git-game/29.sh | tail -n 3
fatal: transport 'file' not allowed
fatal: clone of '/tmp/submod' into submodule path '/tmp/cla-verify.R27R2v/tmp/gamedir29.FgsaTe/lib' failed
VERDICT: FAIL (engine rc=128, timeout=30s)
$ ls -d /tmp/submod
/tmp/submod
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-ident-file /tmp/t-sol-git/verify-legacy.sh git-game 29 tests/solutions/git-game/29.sh | tail -n 3
On branch master
nothing to commit, working tree clean
VERDICT: FAIL (engine rc=1, timeout=30s)
$ rm -rf /tmp/submod
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-ident-file /tmp/t-sol-git/verify-legacy.sh git-game 29 tests/solutions/git-game/29.sh | tail -n 3
[PASS] Submodule added! You linked one repository inside another.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): contract section 4 forbids fixed paths like /tmp/submod, and the evidence shows the cost: a failed run leaves /tmp/submod behind with the legacy engine, so the next setup dies at `git commit` ("nothing to commit"); parallel runs would share it too. Create the source repository under a path derived from `SANDBOX_DIR` (removed in `cleanup_sandbox`), commit there with `git -c user.name=... -c user.email=...`, and do not `cd` in setup. For git 2.38.1 and newer, export `GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=protocol.file.allow GIT_CONFIG_VALUE_0=always` from `setup_sandbox`, or put `git -c protocol.file.allow=always submodule add ...` into the template; both were verified with git 2.43.0 in a scratch repository, a repository-local `git config protocol.file.allow always` does not help.

## levelboss03: no commit contains "BAD" and there is no other branch; validator accepts junk
- Kind: template-wrong
- Also: setup-broken, validator-weak
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\necho x > bad_commit.txt\ngit tag -a v1.0 -m x\ngit log -p --all | grep -c BAD || true\ngit branch -a\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game boss03 /tmp/t-sol-git/exp/p.sh | tail -n 5
0
* master
[PASS] BOSS 03 DEFEATED! You're a Git history rewriting expert!
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): the template says "Commit 7 has BAD" and talks about cherry-picking from another branch, but the sandbox only has ten commits that append "line N" on one branch. boss03.sh uses the first appearance of "line 7" as the stand-in for BAD and builds a side branch with a clean commit itself. Put "BAD" into commit 7, add a branch with a clean fix commit, and validate: bad_commit.txt is a prefix of commit 7's hash, `git cat-file -t v1.0` is `tag`, and the clean commit was cherry-picked (`git cherry`). The current checks (bad_commit.txt exists with any content, a tag matching `v1.0`, at least 10 commits) are all satisfied by the junk probe above, which does no bisect and no cherry-pick.

## level30: setup fails on a default git; setup cds into repo/; validator ignores the commit
- Kind: setup-broken
- Also: contract-violation, validator-weak
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 30 tests/solutions/git-game/30.sh | tail -n 3
[INFO] Replaying Level 30...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 30 tests/solutions/git-game/30.sh | tail -n 3
[PASS] Worktree created! You can work on two branches at once.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ bash /tmp/t-sol-git/sim-contract.sh 30 tests/solutions/git-game/30.sh /tmp/t-sol-git/gitconfig-main | tail -n 4
Preparing worktree (checking out 'feature')
--- validator (cwd=/tmp/cla-sim.h0jnA5/tmp/cliacademy.sokkKy)
Worktree directory not found. Run: git worktree add ../feature-work feature
validator rc=1
SIM RESULT: validator/setup rc=1
$ printf '#!/usr/bin/env bash\nif [[ -d repo ]]; then cd repo; fi\ngit worktree add ../feature-work feature\necho worktree >> ../feature-work/file.txt\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 30 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Worktree created! You can work on two branches at once.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): the legacy engine hides the cwd problem (the shell stays inside repo/ after setup), the contract engine does not: it `cd`s back to `SANDBOX_DIR` (contract section 10), so the honest solution creates `<SANDBOX_DIR>/feature-work` while validate.sh looks for `../feature-work` (third run above). 30.sh therefore stays red after the branch fix until the level is fixed. Do not `cd` in setup, tell the player to `cd repo` in the template, and have the validator use `feature-work` next to `repo` (for example `git -C repo worktree list`). It should also require the commit (`git show feature:file.txt | grep -q worktree`); the last run above passes with an uncommitted edit.

## level31: the template's hook cannot block a WIP commit; validator passes an `exit 0` hook
- Kind: template-wrong
- Also: validator-weak
- Effect: informational
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 31 tests/solutions/git-game/31.sh | grep -E '^\[master|^WIP commits|^second commit|^VERDICT'
[master ae79860] WIP: first draft
WIP commits are not allowed!
second commit was refused by the hook
VERDICT: PASS (engine rc=0, timeout=30s)
$ printf '#!/usr/bin/env bash\nprintf "#!/bin/bash\\nexit 0\\n" > .git/hooks/pre-commit\nchmod +x .git/hooks/pre-commit\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 31 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Hook installed! Your pre-commit hook is working.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): a pre-commit hook has no access to the new message: `git log -1` is the previous commit, so the WIP commit is accepted (the `[master ...] WIP: first draft` line above) and the next, proper commit is the one the hook refuses ("WIP commits are not allowed!", "second commit was refused"). The validator passes anyway because `git commit -m "WIP test"` fails by itself on a clean tree (second probe: a hook that is just `exit 0` passes). Use a `commit-msg` hook (`grep -q WIP "$1" && exit 1`) and let the validator stage a change and check that "WIP test" is refused and a normal message accepted.

## level32: template command alone does not satisfy the template's own check; validator is racy
- Kind: template-wrong
- Also: env-dependent
- Effect: informational
- Evidence:
```text
$ printf '#!/usr/bin/env bash\nexport FILTER_BRANCH_SQUELCH_WARNING=1\ngit filter-branch --tree-filter "rm -f secret.txt" -- --all >/dev/null 2>&1\ngit log --all --name-status | grep secret\ngit for-each-ref --format="%%(refname)"\ntrue\n' > /tmp/t-sol-git/exp/p.sh
$ /tmp/t-sol-git/verify-legacy.sh git-game 32 /tmp/t-sol-git/exp/p.sh | tail -n 7
    Add secret
    Add secret
A	secret.txt
refs/heads/master
refs/original/refs/heads/master
secret.txt still in history.
VERDICT: FAIL (engine rc=1, timeout=30s)
$ bash -c 'd=$(mktemp -d); export HOME=$d GIT_CONFIG_NOSYSTEM=1; cd $d; git init -q; git config user.name T; git config user.email t@e.x; echo s > secret.txt; git add .; git commit -qm "Add secret"; echo p > public.txt; git add .; git commit -qm "Add public file"; git rm -q secret.txt; git commit -qm "Remove secret"; set -o pipefail; t=0; f=0; for _ in $(seq 300); do if git log --all --name-status | grep -q "secret.txt"; then t=$((t+1)); else f=$((f+1)); fi; done; echo "pipeline true=$t false=$f"; cd /; rm -rf "$d"'
pipeline true=281 false=19
```
- Suggested fix (dev team, not applied): `git filter-branch` keeps the old history under `refs/original/`, which `git log --all` still lists, so validate.sh fails after the command the template prescribes (probe above). 32.sh also deletes the backup refs. Mention it in the template (`git update-ref -d refs/original/refs/heads/master`) or make the validator use `--branches --tags`. The template's check `git log --all --name-status | grep secret` always matches the commit message "Add secret"; use `secret.txt`. The validator's own `git log --all --name-status | grep -q "secret.txt"` is racy under `pipefail` (last command above, a repository where secret.txt was only deleted by a new commit: the pipeline reported false in 19 of 300 repetitions, so the validator accepted that attempt in roughly 5 to 8% of runs: 15 of 300 and 16 of 200 against the real validate.sh). Capture the output first (`out="$(git log --all --name-status)"; grep -q 'secret\.txt' <<<"$out"`) or use `[[ -z "$(git rev-list --all -- secret.txt)" ]]`. 32.wrong.sh therefore uses a typo in the filter instead of a plain `git rm`.

## level33: setup fails on a default git; the three branches conflict, so an octopus merge cannot succeed
- Kind: setup-broken
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 33 tests/solutions/git-game/33.sh | tail -n 3
error: pathspec 'main' did not match any file(s) known to git
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 33 tests/solutions/git-game/33.sh | tail -n 8
Simple merge did not work, trying automatic merge.
Auto-merging file.txt
ERROR: content conflict in file.txt
fatal: merge program failed
Automated merge did not work.
Should not be doing an octopus.
Merge with strategy octopus failed.
VERDICT: FAIL (engine rc=2, timeout=30s)
```
- Suggested fix (dev team, not applied): branch fix. All three branches append a line to the same place in file.txt; `merge-octopus` refuses content conflicts ("Should not be doing an octopus"). Let each branch add its own file (feature1.txt, feature2.txt, feature3.txt).

## level34: setup fails on a default git; validator accepts `git config rerere.enabled true` alone, and checks a directory git never creates
- Kind: setup-broken
- Also: validator-weak
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 34 tests/solutions/git-game/34.sh | tail -n 3
[INFO] Replaying Level 34...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 34 tests/solutions/git-game/34.sh | tail -n 3
[PASS] Rerere enabled! Your conflict resolutions are being recorded.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ printf '#!/usr/bin/env bash\ngit config rerere.enabled true\n' > /tmp/t-sol-git/exp/p.sh
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 34 /tmp/t-sol-git/exp/p.sh | tail -n 3
[PASS] Rerere enabled! Your conflict resolutions are being recorded.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
$ bash /tmp/t-sol-git/exp/check-fixes.sh 2>/dev/null | grep '^rrcache exists'
rrcache exists: no; rr-cache exists: yes
```
- Suggested fix (dev team, not applied): branch fix. Enabling the option is enough for the validator and its fallback checks `.git/rrcache` while git creates `.git/rr-cache` (last line above). Require a recorded resolution: `[[ -n $(ls -A .git/rr-cache 2>/dev/null) ]]`.

## level35: setup fails twice on a default git; the honest solution cannot satisfy the commit count
- Kind: setup-broken
- Also: validator-impossible
- Effect: xfail
- Evidence:
```text
$ /tmp/t-sol-git/verify-legacy.sh git-game 35 tests/solutions/git-game/35.sh | tail -n 3
[INFO] Replaying Level 35...
error: pathspec 'main' did not match any file(s) known to git
VERDICT: FAIL (engine rc=1, timeout=30s)
$ CLI_ACADEMY_TEST_GITCONFIG=/tmp/t-sol-git/gitconfig-main /tmp/t-sol-git/verify-legacy.sh git-game 35 tests/solutions/git-game/35.sh | tail -n 3
error: the branch 'feature' is not fully merged.
If you are sure you want to delete it, run 'git branch -D feature'
VERDICT: FAIL (engine rc=1, timeout=30s)
$ bash /tmp/t-sol-git/make-patched.sh with-35 >/dev/null
$ (cd /tmp/t-sol-git/patched && /tmp/t-sol-git/verify-legacy.sh git-game 35 "$OLDPWD/tests/solutions/git-game/35.sh" | tail -n 7)
Previous HEAD position was ab2cb19 Feature commit
Switched to branch 'main'
* e6c0f3f Main commit
* ab2cb19 Feature commit
* 832b251 Initial commit
Final boss validation failed.
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): (1) branch fix; (2) `git branch -d feature` refuses an unmerged branch ("not fully merged"), so setup needs `git branch -D feature` (second run above); (3) the validator wants `git rev-list --count --all` of at least 4, but only 3 commits ever exist (Initial, Feature, Main) and a rebase keeps 3 (third run above, run on a copy with fixes 1 and 2 applied). Check the observable result instead: `git merge-base --is-ancestor feature main`, no merge commits, `git cat-file -t v2.0` is `tag`, branch `feature` exists. Note that validate.sh's `grep -q "  feature"` fails when `feature` is the current branch, so the template should say to finish on main.
