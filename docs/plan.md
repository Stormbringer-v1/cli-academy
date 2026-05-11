# SnapSecurity Academy — Master Plan

> **Lead Architect:** Claude (Opus)
> **Developer:** Robert Harutyunyan
> **Repo:** https://github.com/Stormbringer-v1/vim-game
> **Domain:** snapsecurity.org → academy.snapsecurity.org
> **Last Updated:** 2026-04-04

---

## 1. Project Status: Where We Are

### What Exists

**vim-game** — a 730-line bash script (`play.sh`) with 46 levels (0–45 + boss01) teaching Vim through interactive terminal challenges. Published on GitHub, MIT licensed, fully playable.

### Architecture Assessment (Audit Score: 6/10)

The game works and the level design is creative and well-paced. But the codebase has critical bugs, security issues, and an architecture that cannot scale to multiple games. These must be fixed before building anything new.

#### Critical Bugs (Must Fix Before Anything Else)

| ID | Severity | Issue | Location |
|----|----------|-------|----------|
| BUG-01 | CRITICAL | **Level 25 auto-passes** — the validation is a no-op, level always completes regardless of user action | `play.sh:362` |
| BUG-02 | CRITICAL | **Level 28 modifies user's ~/.vimrc** — permanent side effect on user's real system with no warning or undo | `play.sh:385-390` |
| BUG-03 | CRITICAL | **Level 45 uses `break` inside function** — breaks out of `run_level()` entirely instead of just failing the check, unpredictable behavior | `play.sh:638` |
| BUG-04 | HIGH | **No input validation on replay/hint args** — `./play.sh replay ../../etc` has path traversal risk | `play.sh:19,33` |
| BUG-05 | HIGH | **mktemp portability bug** — `mktemp -t vimlevel${LEVEL}.XXXXXX` behaves differently on Linux vs macOS, unquoted variable | `play.sh:58` |
| BUG-06 | MEDIUM | **grep `\b` not POSIX** — word boundaries using `\b` fail on some systems, inconsistent with `\<\>` used elsewhere | `play.sh:308,418` |
| BUG-07 | LOW | **Hint coverage is 28%** — only levels 0-10 + boss01 have hints, all intermediate/advanced/master levels have none | `levels/` |

#### Code Smells

- **580-line case statement** — each level has unique, non-reusable validation logic hardcoded into play.sh
- **No error handling** — temp files leak on crash, no trap, no cleanup
- **No atomic progress writes** — concurrent runs corrupt progress.log
- **Inconsistent patterns** — 4+ different validation approaches mixed together
- **.gitignore incomplete** — .DS_Store committed, gameplay temp files not ignored

### Verdict

**Do NOT start building new games yet.** The vim-game needs a bugfix pass and then an engine extraction. Building a git-game on top of the current architecture would mean copying 730 lines of monolithic code and repeating all the same problems.

The correct order is:
1. Fix critical bugs in vim-game
2. Extract the game engine
3. Refactor vim-game to use the engine
4. Only THEN build game #2

---

## 2. Project Vision: Where We're Going

A gamified, terminal-first learning platform for CLI tools.

- **Terminal version:** Self-hosted, bash-only, zero dependencies — `git clone && ./play.sh`
- **Web version (future):** academy.snapsecurity.org with sandboxed terminal emulator
- **Business model:** Freemium — games free, combined certification exams paid
- **Target audience:** DevOps engineers, sysadmins, CS students, career changers

---

## 3. Game Catalog

### 3.0 Summary Table

| # | Game | Levels | Dependency | Sandbox | Phase | Status |
|---|------|--------|------------|---------|-------|--------|
| 1 | vim-game | 46 | vim | Trivial (temp file) | 0 | EXISTS — needs bugfix |
| 2 | git-game | 38 | git | Easy (temp repos) | 1 | NOT STARTED |
| 3 | bash-game | 40 | bash | Easy (restricted shell) | 2 | NOT STARTED |
| 4 | tmux-game | 30 | tmux | Easy (isolated socket) | 2 | NOT STARTED |
| 5 | docker-game | 35 | docker | Medium (dedicated context) | 2 | NOT STARTED |
| 6 | virsh-game | 25 | libvirt + qemu | Hard (nested virt or mock) | 3 | NOT STARTED |
| 7 | iptables-game | 30 | iptables/nftables | Medium (net namespace) | 3 | NOT STARTED |
| 8 | sysops-game | 20 | ps, kill, htop, lsof, ss | Easy (simulated procs) | 3 | NOT STARTED |
| 9 | systemd-game | 25 | systemd | Medium (container) | 3 | NOT STARTED |
| 10 | ssh-game | 25 | openssh | Medium (container target) | 4 | NOT STARTED |

**Total: 10 games, ~314 levels**

Architect's note: I added **systemd-game** to Robert's list because it's deeply connected to iptables (firewalld wraps iptables), virsh (libvirtd is a systemd service), and docker (containerd runs under systemd). You can't be a real Linux admin without understanding systemd, and it fits perfectly between the other games.

---

### 3.1 vim-game (EXISTS — Phase 0: Bugfix)

**Repository:** https://github.com/Stormbringer-v1/vim-game
**Dependency:** vim
**Current state:** 46 levels, playable, has critical bugs

#### Level Map (current)

```
BEGINNER (0-10)
  0  — Quit Vim (:wq)
  1  — Fix a typo (x, i)
  2  — Delete a line (dd)
  3  — Replace a word (cw)
  4  — Another typo fix (r)
  5  — Undo/redo (u, Ctrl-r)
  6  — Find and replace (:%s)
  7  — Create a second file (:e, :w)
  8  — Split and write (:split, :w)
  9  — Delete multiple lines (visual + d)
  10 — Visual mode editing (v, V)
  BOSS 01 — Combine delete + typo fix + replace

INTERMEDIATE (11-20)
  11 — Block visual delete (Ctrl-v)
  12 — Multi-buffer editing (:e, :b)
  13 — Cursed level (no arrows, no backspace)
  14 — Tabs (:tabnew, gt)
  15 — Global delete (:g/pattern/d)
  16 — Yank and paste (yy, p)
  17 — Macro basics (qa, @a)
  18 — Prepend text to lines (visual block I)
  19 — Sessions (:mksession)
  20 — Mini-boss: cleanup crew

ADVANCED (21-30)
  21 — Folds (zf, zo, zc)
  22 — Marks and jumps (ma, 'a)
  23 — Text objects (ci", da()
  24 — Named marks
  25 — Window splits (:vsplit) [BUG: auto-passes]
  26 — Diff mode (:diffthis)
  27 — Shell commands (:!, :r!)
  28 — vimrc basics [BUG: modifies ~/.vimrc]
  29 — Spell check (:set spell)
  30 — Boss: multi-fix cleanup

MASTER (31-45)
  31 — TODO conversion (macros + substitution)
  32 — Multi-file arglist (:argdo)
  33 — Multi-file substitution
  34 — Abbreviations and mappings
  35 — Autocommands (autocmd)
  36 — Window magic
  37 — Sort (:sort)
  38 — Custom commands
  39 — Regex with capture groups
  40 — Mini-boss: project setup
  41 — Cross-file copy
  42 — Name reordering (regex)
  43 — Bullet formatting
  44 — Checkbox conversion
  45 — FINAL BOSS [BUG: broken control flow]
```

#### Sandbox Strategy
- Trivial: copy template.txt to temp file, open in vim, validate on exit
- No isolation needed beyond temp files

#### Phase 0 Tasks → See Section 5.0

---

### 3.2 git-game (Phase 1)

**Dependency:** git (>= 2.20)
**Levels:** 38 (30 regular + 5 boss checkpoints + 3 boss fights)

#### Why git is game #2
Highest demand after vim. Easy to sandbox (temp repos in /tmp). Every developer needs it. The sandbox pattern (setup.sh creates a pre-built repo) is fundamentally different from vim-game, which proves the engine is truly generic.

#### Level Map

```
BEGINNER (0-9): First Commits
  0  — git init (create your first repo)
  1  — git config (set name and email in the repo)
  2  — git add (stage a file)
  3  — git commit (make your first commit)
  4  — git status (read the status output, answer a question by creating a file)
  5  — git log (find a specific commit message, write its hash to a file)
  6  — git diff (identify what changed, fix it)
  7  — .gitignore (stop tracking a file that shouldn't be tracked)
  8  — git rm / git mv (rename and remove files properly)
  9  — git commit --amend (fix a bad commit message)
  BOSS 01 — Init a repo, configure it, add files, make 3 commits with proper messages,
            set up .gitignore, amend the last commit message

INTERMEDIATE (10-19): Branching & Merging
  10 — git branch (create a branch)
  11 — git checkout / git switch (switch between branches)
  12 — git merge (fast-forward merge)
  13 — git merge (3-way merge, no conflicts)
  14 — git merge (resolve a conflict — the real test)
  15 — git stash (save work, switch branch, come back)
  16 — git stash pop vs git stash apply
  17 — git log --graph (read a branching history, answer questions)
  18 — git branch -d / -D (clean up merged branches)
  19 — git remote + git fetch (understand remote tracking)
  BOSS 02 — Create feature branch, make commits, merge with conflicts,
            stash changes mid-work, clean up branches after merge

ADVANCED (20-29): Rewriting History
  20 — git rebase (rebase a feature branch onto main)
  21 — git rebase --onto (move commits between branches)
  22 — git cherry-pick (grab a specific commit from another branch)
  23 — git revert (undo a commit without rewriting history)
  24 — git reset --soft/--mixed/--hard (understand the 3 modes)
  25 — git reflog (recover a "lost" commit after bad reset)
  26 — git bisect (find the commit that introduced a bug)
  27 — git tag (create annotated tags, list tags)
  28 — git blame (find who changed a specific line)
  29 — git submodule (add and update a submodule)
  BOSS 03 — Repo has a bug introduced 10 commits ago. Use bisect to find it,
            cherry-pick the fix from a different branch, tag the release.

MASTER (30-35): Expert Workflows
  30 — git worktree (work on two branches simultaneously)
  31 — git hooks (pre-commit hook that enforces a rule)
  32 — git filter-branch / git-filter-repo (remove a large file from history)
  33 — Octopus merge (merge 3+ branches at once)
  34 — git rerere (reuse recorded resolution)
  35 — FINAL BOSS — Real-world scenario: you join a messy repo with diverged branches,
       bad merges, a secret committed to history, and broken hooks. Fix everything.
```

#### Sandbox Strategy

```bash
# sandbox.sh for git-game

setup_sandbox() {
  local LEVEL="$1"
  SANDBOX_DIR="$(mktemp -d "/tmp/gitgame_level${LEVEL}.XXXXXX")"
  cd "$SANDBOX_DIR"
  git init -q
  git config user.name "Player"
  git config user.email "player@cli-academy.local"

  # Run level-specific setup (creates commits, branches, conflicts, etc.)
  source "${GAME_DIR}/levels/level${LEVEL}/setup.sh"

  # Drop user into a shell in the repo
  export PS1="[git-game:level${LEVEL}] \w $ "
  echo "Type 'exit' when you're done."
  bash --norc --noprofile
}

cleanup_sandbox() {
  rm -rf "$SANDBOX_DIR"
}
```

Each level's `setup.sh` builds the specific repo state. Example for Level 14 (merge conflict):

```bash
# levels/level14/setup.sh — creates a repo with a merge conflict
echo "Hello World" > greeting.txt
git add greeting.txt && git commit -q -m "Initial commit"

git checkout -q -b feature
echo "Hello Universe" > greeting.txt
git add greeting.txt && git commit -q -m "Change greeting on feature"

git checkout -q main
echo "Hello Planet" > greeting.txt
git add greeting.txt && git commit -q -m "Change greeting on main"

# Now 'git merge feature' will create a conflict for the player to resolve
```

#### Validation Approach
Most levels use `command_check` or `script` validators:
- Check branch list: `git branch --list | grep -q "expected-branch"`
- Check commit count: `git rev-list --count HEAD`
- Check commit message: `git log -1 --format=%s | grep -q "expected message"`
- Check merge state: `git merge HEAD --no-commit 2>/dev/null; echo $?`
- Check file state: compare working tree to expected state

---

### 3.3 bash-game (Phase 2)

**Dependency:** bash (>= 4.0)
**Levels:** 40 (34 regular + 3 boss fights + 3 checkpoints)

#### Why bash is game #3
It's the foundation everything else runs on. Every single other game in this platform uses bash. Teaching it explicitly makes players better at all the other games too.

#### Level Map

```
BEGINNER (0-9): Shell Basics
  0  — Echo and exit (echo "hello", exit 0)
  1  — Variables (NAME="world"; echo "Hello $NAME")
  2  — Quoting (single vs double vs none — when it matters)
  3  — Exit codes ($? — run a command, check its exit code)
  4  — Conditionals: if/then/else/fi
  5  — Test expressions ([[ -f file ]], [[ $x -gt 5 ]])
  6  — Read user input (read -p)
  7  — For loops (for i in 1 2 3; do ...; done)
  8  — While loops (while read line; do ...; done)
  9  — Case statements (case $input in ...)
  BOSS 01 — Write a script that reads a number, checks if it's positive/negative/zero,
            loops N times printing a countdown, exits with appropriate code

INTERMEDIATE (10-19): Pipes and Files
  10 — Pipes (cmd1 | cmd2 | cmd3)
  11 — Redirection: stdout (> and >>)
  12 — Redirection: stderr (2> and 2>&1)
  13 — Here documents (cat <<EOF)
  14 — grep basics (grep, grep -i, grep -v, grep -c)
  15 — sed basics (sed 's/old/new/g', sed '/pattern/d')
  16 — awk basics (awk '{print $1}', awk -F: '{print $1}')
  17 — sort + uniq (sort | uniq -c | sort -rn)
  18 — cut + paste + tr (field extraction and character translation)
  19 — xargs (find ... | xargs ...)
  BOSS 02 — Given a messy log file: extract error lines, count unique error types,
            sort by frequency, output top 5 to a report file

ADVANCED (20-29): Functions and Process Control
  20 — Functions (define, call, return values)
  21 — Local variables in functions (local keyword)
  22 — Command substitution ($(command) vs backticks)
  23 — Arithmetic ($(( )), let, (( )))
  24 — Arrays (declare -a, ${arr[@]}, ${#arr[@]})
  25 — Associative arrays (declare -A)
  26 — Process substitution (<(cmd) and >(cmd))
  27 — Traps (trap 'cleanup' EXIT)
  28 — Background jobs (&, wait, jobs, fg, bg)
  29 — Signal handling (trap 'handler' SIGTERM SIGINT)
  BOSS 03 — Write a script that: defines functions, uses arrays, traps signals
            for cleanup, processes files in parallel with &/wait

MASTER (30-37): Real-World Scripting
  30 — getopts (parse command-line flags: -v, -f FILE, -h)
  31 — Error handling patterns (set -euo pipefail, || exit 1)
  32 — Here strings and process redirection (<<< "string")
  33 — String manipulation (${var#pattern}, ${var%pattern}, ${var//old/new})
  34 — Advanced regex with grep -E and sed -E
  35 — find + exec (find . -name "*.log" -exec grep "ERROR" {} +)
  36 — Debugging (set -x, PS4, trap DEBUG)
  37 — FINAL BOSS — Write a complete deployment script: parse args with getopts,
       validate environment, process a config file, handle errors with traps,
       log everything, and return proper exit codes
```

#### Sandbox Strategy

```bash
# sandbox.sh for bash-game

setup_sandbox() {
  local LEVEL="$1"
  SANDBOX_DIR="$(mktemp -d "/tmp/bashgame_level${LEVEL}.XXXXXX")"

  # Copy any level-specific input files
  if [[ -d "${GAME_DIR}/levels/level${LEVEL}/files" ]]; then
    cp -r "${GAME_DIR}/levels/level${LEVEL}/files/"* "$SANDBOX_DIR/"
  fi

  cd "$SANDBOX_DIR"

  # Player writes their script, we validate the output
  export PS1="[bash-game:level${LEVEL}] \w $ "
  echo "Write your solution in solution.sh, then type 'exit' when done."
  bash --norc --noprofile
}
```

#### Validation Approach
Most levels validate by running the player's `solution.sh` and checking output:
- Run the script with test inputs
- Compare stdout to expected output
- Check exit code
- For file-manipulation levels, check the resulting files
- For advanced levels, check that specific patterns are used (`grep 'trap' solution.sh`)

---

### 3.4 tmux-game (Phase 2)

**Dependency:** tmux (>= 3.0)
**Levels:** 30 (25 regular + 2 boss fights + 3 checkpoints)

#### Level Map

```
BEGINNER (0-9): Sessions and Windows
  0  — Start tmux (tmux new-session — just get in and get out with Ctrl-b d)
  1  — Name a session (tmux new -s mysession)
  2  — List sessions (tmux ls)
  3  — Attach/detach (tmux attach -t name, Ctrl-b d)
  4  — Create a new window (Ctrl-b c)
  5  — Switch windows (Ctrl-b n, Ctrl-b p, Ctrl-b 0-9)
  6  — Rename a window (Ctrl-b ,)
  7  — Close a window (exit or Ctrl-b &)
  8  — Kill a session (tmux kill-session -t name)
  9  — Multiple sessions (create 2, switch between them)
  BOSS 01 — Create 2 named sessions, each with 3 named windows, detach from one,
            attach to the other, kill the first

INTERMEDIATE (10-19): Panes and Layouts
  10 — Horizontal split (Ctrl-b ")
  11 — Vertical split (Ctrl-b %)
  12 — Navigate panes (Ctrl-b arrow keys)
  13 — Resize panes (Ctrl-b Ctrl-arrow or Ctrl-b :resize-pane)
  14 — Zoom a pane (Ctrl-b z — toggle fullscreen on one pane)
  15 — Preset layouts (Ctrl-b Space, or select-layout)
  16 — Move panes between windows (join-pane, break-pane)
  17 — Synchronize panes (setw synchronize-panes on)
  18 — Swap panes (swap-pane -U/-D)
  19 — Send keys to another pane (tmux send-keys -t)
  BOSS 02 — Set up a "monitoring dashboard": 4 panes, specific layout,
            rename the window "monitor", run a command in each pane

ADVANCED (20-27): Copy Mode and Scripting
  20 — Copy mode (Ctrl-b [ — navigate, search, select, copy)
  21 — Paste buffer (Ctrl-b ])
  22 — tmux command mode (Ctrl-b : — run tmux commands)
  23 — tmux.conf basics (set options: mouse on, change prefix key)
  24 — Status bar customization (set -g status-right)
  25 — tmux scripting (write a .sh that creates a full layout)
  26 — Hooks (set-hook after-new-session, after-split-window)
  27 — FINAL BOSS — Write a tmux script that creates a complete development
       environment: named session, 4 windows (editor, server, logs, shell),
       specific pane layouts in each, proper status bar
```

#### Sandbox Strategy

```bash
# sandbox.sh for tmux-game
# Uses an ISOLATED tmux server (separate socket) so we never touch user's tmux

TMUX_SOCKET="/tmp/tmuxgame_$$"

setup_sandbox() {
  local LEVEL="$1"
  # Kill any leftover game server
  tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true

  # Some levels need pre-existing sessions
  if [[ -f "${GAME_DIR}/levels/level${LEVEL}/setup.sh" ]]; then
    source "${GAME_DIR}/levels/level${LEVEL}/setup.sh"
  fi

  # Drop user into tmux on our isolated socket
  export TMUX_GAME_SOCKET="$TMUX_SOCKET"
  echo "You're entering an isolated tmux environment."
  echo "Your real tmux sessions are NOT affected."
  echo "Type 'exit' in all panes to finish."
  tmux -L "$TMUX_SOCKET" new-session
}

cleanup_sandbox() {
  tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true
  rm -f "/tmp/tmuxgame_$$"
}
```

#### Validation Approach
Validate tmux state via tmux commands on the isolated socket:
- `tmux -L $SOCKET list-sessions` → check session names/count
- `tmux -L $SOCKET list-windows -t session` → check window names/count
- `tmux -L $SOCKET list-panes -t session:window` → check pane count/layout
- `tmux -L $SOCKET display-message -p "#{...}"` → check specific options
- `tmux -L $SOCKET capture-pane -p -t session:window.pane` → check pane content

---

### 3.5 docker-game (Phase 2)

**Dependency:** docker (>= 20.10)
**Levels:** 35 (28 regular + 4 boss fights + 3 checkpoints)

#### Level Map

```
BEGINNER (0-9): Containers 101
  0  — docker run (run hello-world)
  1  — docker ps (list running containers)
  2  — docker ps -a (see stopped containers too)
  3  — docker run -it (interactive: run bash inside ubuntu)
  4  — docker run -d (detached: run nginx in background)
  5  — docker exec (exec into a running container)
  6  — docker stop / docker rm (lifecycle management)
  7  — docker logs (read container logs)
  8  — docker inspect (find a container's IP address)
  9  — docker run --name (named containers)
  BOSS 01 — Run nginx detached, exec into it, change the default page,
            verify with curl, check logs, stop and remove it

INTERMEDIATE (10-19): Images and Storage
  10 — docker images (list local images)
  11 — docker pull (pull a specific image version/tag)
  12 — Dockerfile basics (FROM, RUN, COPY, CMD)
  13 — docker build (build an image from a Dockerfile)
  14 — Multi-line RUN and layer optimization
  15 — docker volumes (create, mount with -v)
  16 — Bind mounts (-v /host/path:/container/path)
  17 — docker cp (copy files to/from containers)
  18 — docker commit (create image from running container — and why you shouldn't)
  19 — .dockerignore
  BOSS 02 — Write a Dockerfile for a Python app, build it, run it with a volume
            for persistent data, verify the app works

ADVANCED (20-27): Networking and Compose
  20 — docker network ls (list networks)
  21 — docker network create (create a custom bridge)
  22 — Container-to-container networking (by name on custom network)
  23 — Port mapping (-p hostPort:containerPort)
  24 — docker-compose up (multi-container app from yaml)
  25 — docker-compose services, depends_on, environment
  26 — docker-compose volumes and networks
  27 — docker system prune (cleanup dangling images, volumes, containers)
  BOSS 03 — Write a docker-compose.yml for a 3-tier app: nginx frontend,
            python api, postgres database. All connected, all working.

MASTER (28-32): Production Patterns
  28 — Multi-stage builds (builder pattern for small final images)
  29 — Health checks (HEALTHCHECK in Dockerfile)
  30 — Resource limits (--memory, --cpus)
  31 — Docker debugging (docker stats, docker top, docker events)
  32 — FINAL BOSS — Given a broken docker-compose setup with 4 services:
       fix the Dockerfile (wrong base image, missing deps), fix the compose
       (wrong ports, missing volumes, bad network config), get it all running,
       verify every service is healthy.
```

#### Sandbox Strategy

```bash
# sandbox.sh for docker-game
# Uses a dedicated Docker context or prefix to isolate from user's containers

GAME_PREFIX="cliacademy_"

setup_sandbox() {
  local LEVEL="$1"
  SANDBOX_DIR="$(mktemp -d "/tmp/dockergame_level${LEVEL}.XXXXXX")"

  # Copy level files (Dockerfiles, compose files, app code)
  if [[ -d "${GAME_DIR}/levels/level${LEVEL}/files" ]]; then
    cp -r "${GAME_DIR}/levels/level${LEVEL}/files/"* "$SANDBOX_DIR/"
  fi

  cd "$SANDBOX_DIR"

  # Run level-specific setup
  if [[ -f "${GAME_DIR}/levels/level${LEVEL}/setup.sh" ]]; then
    source "${GAME_DIR}/levels/level${LEVEL}/setup.sh"
  fi

  export PS1="[docker-game:level${LEVEL}] \w $ "
  echo "Type 'exit' when you're done."
  bash --norc --noprofile
}

cleanup_sandbox() {
  # Remove all game-prefixed containers, images, volumes, networks
  docker ps -a --filter "name=${GAME_PREFIX}" -q | xargs -r docker rm -f 2>/dev/null
  docker images --filter "reference=${GAME_PREFIX}*" -q | xargs -r docker rmi -f 2>/dev/null
  docker volume ls --filter "name=${GAME_PREFIX}" -q | xargs -r docker volume rm 2>/dev/null
  docker network ls --filter "name=${GAME_PREFIX}" -q | xargs -r docker network rm 2>/dev/null
  rm -rf "$SANDBOX_DIR"
}
```

#### Validation Approach
- `docker ps --filter "name=..." --format "{{.Status}}"` → check running state
- `docker exec container cat /path/to/file` → check file content inside container
- `curl -s localhost:PORT` → check exposed service
- `docker inspect --format '{{...}}' container` → check config details
- `docker images --format "{{.Repository}}:{{.Tag}}"` → check built images
- `docker-compose ps` → check compose service state

#### Important Note for Agents
Docker-game has a hard dependency: the player must have Docker installed and running. The game MUST check this at startup with a clear error message. Also, all container/image/volume/network names MUST use the `cliacademy_` prefix to avoid colliding with the player's real Docker resources.

---

### 3.6 virsh-game (Phase 3)

**Dependency:** libvirt + qemu-kvm + virsh
**Levels:** 25 (20 regular + 2 boss fights + 3 checkpoints)

#### Architecture Decision: Mock vs Real

Nested virtualization is unreliable (not supported on all machines, requires specific CPU flags). Real VMs are slow to create/destroy. My recommendation:

**Approach: Use real libvirt with lightweight test domains.** Instead of creating full VMs (which need disk images and are slow), we use:
1. `virsh define` with XML that describes a domain but doesn't boot it (for management operations)
2. Tiny Alpine-based qcow2 images (50MB) for levels that need a running VM
3. Pre-built XML definitions for levels about networking, storage pools, snapshots

For levels that need a "running" VM, we ship a minimal qcow2 or use `virt-install --import` with a tiny cloud image. This adds a ~50MB download but keeps things realistic.

#### Level Map

```
BEGINNER (0-9): Domain Basics
  0  — virsh list --all (see what domains exist)
  1  — virsh define (define a domain from XML — we provide the XML)
  2  — virsh start (start a defined domain)
  3  — virsh shutdown / virsh destroy (graceful vs forced stop)
  4  — virsh undefine (remove a domain definition)
  5  — virsh dominfo (inspect domain details: memory, vCPUs, state)
  6  — virsh console (connect to a running domain's console)
  7  — virsh dumpxml (export domain XML configuration)
  8  — virsh edit (modify domain XML: change memory, vCPUs)
  9  — virsh autostart (set domain to auto-start on host boot)
  BOSS 01 — Define 2 domains from XML, start one, change the other's memory
            to 2048MB, set both to autostart, verify with virsh list and dominfo

INTERMEDIATE (10-17): Storage and Networking
  10 — virsh pool-list (list storage pools)
  11 — virsh pool-define / pool-create (create a directory-based storage pool)
  12 — virsh vol-create-as (create a volume in a pool)
  13 — virsh vol-list / vol-info (inspect volumes)
  14 — virsh net-list (list virtual networks)
  15 — virsh net-define / net-create (create a NAT network from XML)
  16 — virsh net-info / net-dumpxml (inspect network details)
  17 — virsh attach-interface (hotplug a NIC to a running domain)
  BOSS 02 — Create a storage pool, create a volume, create a network,
            define a domain that uses both the volume and network

ADVANCED (18-22): Snapshots and Migration
  18 — virsh snapshot-create-as (create a named snapshot)
  19 — virsh snapshot-list (list snapshots of a domain)
  20 — virsh snapshot-revert (revert to a snapshot)
  21 — virsh snapshot-delete (clean up snapshots)
  22 — virsh domstats (monitor domain performance: CPU, memory, disk, net)

MASTER (23-24): Expert Operations
  23 — virsh blockcopy / blockcommit (live storage migration)
  24 — FINAL BOSS — A domain is misconfigured: wrong network, insufficient
       memory, no storage pool, no snapshots. Fix the XML, create proper
       storage and network, take a clean snapshot, verify everything.
```

#### Sandbox Strategy

```bash
# sandbox.sh for virsh-game
# Requires: libvirtd running, user in libvirt group
# All domains/pools/networks use "game_" prefix

GAME_PREFIX="game_"

setup_sandbox() {
  local LEVEL="$1"
  SANDBOX_DIR="$(mktemp -d "/tmp/virshgame_level${LEVEL}.XXXXXX")"

  # Copy XML definitions and any disk images
  if [[ -d "${GAME_DIR}/levels/level${LEVEL}/files" ]]; then
    cp -r "${GAME_DIR}/levels/level${LEVEL}/files/"* "$SANDBOX_DIR/"
  fi

  cd "$SANDBOX_DIR"

  if [[ -f "${GAME_DIR}/levels/level${LEVEL}/setup.sh" ]]; then
    source "${GAME_DIR}/levels/level${LEVEL}/setup.sh"
  fi

  export PS1="[virsh-game:level${LEVEL}] \w $ "
  bash --norc --noprofile
}

cleanup_sandbox() {
  # Destroy and undefine all game-prefixed domains
  for dom in $(virsh list --all --name | grep "^${GAME_PREFIX}"); do
    virsh destroy "$dom" 2>/dev/null || true
    virsh undefine "$dom" --snapshots-metadata 2>/dev/null || true
  done
  # Remove game-prefixed pools and networks
  for pool in $(virsh pool-list --all --name | grep "^${GAME_PREFIX}"); do
    virsh pool-destroy "$pool" 2>/dev/null || true
    virsh pool-undefine "$pool" 2>/dev/null || true
  done
  for net in $(virsh net-list --all --name | grep "^${GAME_PREFIX}"); do
    virsh net-destroy "$net" 2>/dev/null || true
    virsh net-undefine "$net" 2>/dev/null || true
  done
  rm -rf "$SANDBOX_DIR"
}
```

#### Validation Approach
- `virsh domstate game_domain` → check running/shutoff
- `virsh dominfo game_domain | grep "Max memory"` → check config
- `virsh snapshot-list game_domain --name` → check snapshots
- `virsh net-list --name | grep game_network` → check network exists
- `virsh pool-info game_pool` → check storage pool state

#### Important Note for Agents
The virsh-game has the heaviest system requirement of all games. The game MUST check at startup: (1) libvirtd is running, (2) user has virsh access, (3) KVM is available (`/dev/kvm` exists). Provide clear error messages explaining how to install/enable each prerequisite. Consider providing a setup-prerequisites.sh helper script.

---

### 3.7 iptables-game (Phase 3)

**Dependency:** iptables or nftables, plus network namespaces (ip netns)
**Levels:** 30 (24 regular + 3 boss fights + 3 checkpoints)

#### Architecture Decision: iptables vs nftables

Both. iptables is still widely deployed and the concepts are foundational. nftables is the modern replacement. The game teaches iptables first (because it's simpler and more documented), then introduces nftables as the "advanced" tier. This mirrors real-world learning paths.

#### Sandbox Strategy (CRITICAL)

Firewall rules are DANGEROUS to play with on a real system. We MUST use Linux network namespaces to create a fully isolated network environment. This is the one game that **cannot run directly on macOS** — it requires Linux or a Linux VM.

```bash
# sandbox.sh for iptables-game
# Creates isolated network namespaces — NEVER touches host iptables

GAME_NS="iptgame_$$"

setup_sandbox() {
  local LEVEL="$1"

  # Create isolated network namespace
  sudo ip netns add "${GAME_NS}"

  # Create a veth pair linking host to namespace
  sudo ip link add veth_host type veth peer name veth_game
  sudo ip link set veth_game netns "${GAME_NS}"

  # Configure IPs
  sudo ip addr add 10.99.0.1/24 dev veth_host
  sudo ip link set veth_host up
  sudo ip netns exec "${GAME_NS}" ip addr add 10.99.0.2/24 dev veth_game
  sudo ip netns exec "${GAME_NS}" ip link set veth_game up
  sudo ip netns exec "${GAME_NS}" ip link set lo up

  # Level-specific network setup (extra interfaces, routes, etc.)
  if [[ -f "${GAME_DIR}/levels/level${LEVEL}/setup.sh" ]]; then
    source "${GAME_DIR}/levels/level${LEVEL}/setup.sh"
  fi

  echo "You're inside an isolated network namespace."
  echo "IP: 10.99.0.2/24 | Gateway: 10.99.0.1"
  echo "Your real firewall rules are NOT affected."
  echo "Type 'exit' when done."
  sudo ip netns exec "${GAME_NS}" bash --norc --noprofile
}

cleanup_sandbox() {
  sudo ip netns delete "${GAME_NS}" 2>/dev/null || true
  sudo ip link delete veth_host 2>/dev/null || true
}
```

#### Level Map

```
BEGINNER (0-9): iptables Fundamentals
  0  — iptables -L (list current rules — they're empty, that's ok)
  1  — Chains explained (INPUT, OUTPUT, FORWARD — read and identify)
  2  — iptables -A INPUT -p icmp -j DROP (block ping)
  3  — iptables -A INPUT -p tcp --dport 22 -j ACCEPT (allow SSH)
  4  — iptables -D (delete a rule by specification)
  5  — iptables -I (insert at position — order matters!)
  6  — iptables -P INPUT DROP (set default policy — then whitelist)
  7  — iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  8  — iptables-save / iptables-restore (persist rules)
  9  — iptables -A INPUT -s 10.99.0.0/24 -j ACCEPT (source IP filtering)
  BOSS 01 — Set up a basic firewall: default DROP on INPUT, allow SSH (22),
            HTTP (80), HTTPS (443), allow established connections, allow loopback

INTERMEDIATE (10-19): Advanced iptables
  10 — LOG target (iptables -A INPUT -j LOG --log-prefix "DROPPED: ")
  11 — REJECT vs DROP (and when to use which)
  12 — Rate limiting (-m limit --limit 5/min)
  13 — Port ranges (--dport 8000:8100)
  14 — Multiple ports (-m multiport --dports 22,80,443)
  15 — NAT basics: SNAT (iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE)
  16 — NAT: DNAT / port forwarding (-t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to 10.99.0.2:8080)
  17 — Custom chains (iptables -N LOGGING, -A INPUT -j LOGGING)
  18 — Connection tracking in depth (-m conntrack --ctstate)
  19 — iptables for Docker (understand DOCKER chain, DOCKER-USER)
  BOSS 02 — Set up a router/NAT: 2 namespaces connected through yours,
            SNAT outbound, DNAT port 80 to backend, rate-limit SSH, log drops

ADVANCED (20-27): nftables
  20 — nft list ruleset (see the nftables equivalent of iptables -L)
  21 — nft add table / nft add chain (create table and base chain)
  22 — nft add rule (basic rule syntax comparison with iptables)
  23 — nft sets (group IPs or ports into named sets)
  24 — nft maps (translate one value to another in a rule)
  25 — nft counter (packet/byte counters on rules)
  26 — nft scripting (load a complete ruleset from a file)
  27 — nft vs iptables (translate an iptables ruleset to nft)
  BOSS 03 — Recreate Boss 02's entire firewall using nftables instead of iptables

MASTER (28-29)
  28 — Debugging: nft monitor + conntrack -L (trace packet flow)
  29 — FINAL BOSS — A namespace has broken networking: some rules are wrong,
       NAT is misconfigured, a critical port is blocked, and there's a rule
       ordering bug. Diagnose with nft monitor, fix everything, verify.
```

#### Validation Approach
- `sudo ip netns exec $NS iptables -L -n` → parse rule list
- `sudo ip netns exec $NS nft list ruleset` → check nftables rules
- `sudo ip netns exec $NS ping -c1 -W1 10.99.0.1` → test connectivity
- `sudo ip netns exec $NS curl -s --connect-timeout 2 http://10.99.0.1:80` → test port access
- `sudo ip netns exec $NS iptables-save | grep -c "ACCEPT"` → count rules

#### Important Note for Agents
This game requires sudo/root access for network namespace operations. The game MUST check at startup that the user can run `sudo ip netns` without error. It MUST clearly state this is a Linux-only game. On macOS, show a message suggesting to use a Linux VM or container.

---

### 3.8 htop-game (Phase 3)

**Dependency:** htop or btop, plus standard Linux process tools (ps, kill, nice, top)
**Levels:** 20 (17 regular + 1 boss fight + 2 checkpoints)

#### Architecture Decision

htop/btop are interactive TUI tools — you can't easily "validate" what someone did inside them. The approach: this game teaches **process management and system monitoring** using both the command-line tools (ps, kill, nice, renice, /proc) AND the interactive tools (htop, btop, top). The levels alternate between "do this with ps/kill" and "do this inside htop".

For htop-specific levels, we spawn background processes that the player must find and manage. Validation checks the process state after the player exits htop.

#### Level Map

```
BEGINNER (0-7): Process Basics
  0  — ps aux (read the output — find a specific process, write its PID to a file)
  1  — ps aux | grep (filter processes by name)
  2  — pgrep / pidof (find PID by name without grep)
  3  — kill (send SIGTERM to a process we spawned)
  4  — kill -9 (SIGKILL — when SIGTERM isn't enough)
  5  — top basics (launch top, read the header: load, memory, CPU — answer questions)
  6  — htop basics (launch htop, find a process by name, kill it with F9)
  7  — htop tree view (F5 — identify parent-child relationships)
  BOSS 01 — We spawn 5 rogue processes. Find them all, kill 3 gracefully,
            force-kill 2 that ignore SIGTERM, verify they're all gone.

INTERMEDIATE (8-13): Priority and Resources
  8  — nice (run a command with lower priority)
  9  — renice (change priority of a running process)
  10 — htop: renice a process (F7/F8 to change nice value)
  11 — /proc filesystem (read /proc/PID/status, /proc/PID/cmdline)
  12 — /proc/meminfo and /proc/cpuinfo (find specific system info)
  13 — Understanding load average (what do the 3 numbers mean?)

ADVANCED (14-18): Monitoring and Debugging
  14 — btop basics (launch btop, read CPU/memory/network/disk graphs)
  15 — strace basics (strace -p PID — identify what syscalls a process makes)
  16 — lsof (find which process has a file/port open)
  17 — ss / netstat (find which process is listening on a port)
  18 — vmstat / iostat / mpstat (read system performance metrics)

MASTER (19)
  19 — FINAL BOSS — System is "slow": multiple rogue processes eating CPU,
       a process holding a file lock, one listening on a port it shouldn't be.
       Use ps/htop/lsof/ss to diagnose everything and fix it.
```

#### Sandbox Strategy

```bash
# sandbox.sh for htop-game
# Spawns background "rogue" processes for the player to find and manage

GAME_PIDS=()

setup_sandbox() {
  local LEVEL="$1"
  SANDBOX_DIR="$(mktemp -d "/tmp/htopgame_level${LEVEL}.XXXXXX")"
  cd "$SANDBOX_DIR"

  # Level-specific setup spawns background processes
  if [[ -f "${GAME_DIR}/levels/level${LEVEL}/setup.sh" ]]; then
    source "${GAME_DIR}/levels/level${LEVEL}/setup.sh"
  fi

  export PS1="[htop-game:level${LEVEL}] \w $ "
  bash --norc --noprofile
}

cleanup_sandbox() {
  # Kill any game processes still running
  for pid in "${GAME_PIDS[@]}"; do
    kill -9 "$pid" 2>/dev/null || true
  done
  rm -rf "$SANDBOX_DIR"
}

# Helper used by setup.sh scripts
spawn_rogue() {
  local NAME="$1"
  local CPU="${2:-0}"  # 0 = idle, 1 = busy
  if [[ "$CPU" == "1" ]]; then
    bash -c "while true; do :; done" &
  else
    sleep 99999 &
  fi
  GAME_PIDS+=($!)
  # Rename process for easy identification
  echo "$!" > "${SANDBOX_DIR}/.${NAME}.pid"
}
```

#### Validation Approach
- Check if specific PIDs are still alive: `kill -0 $PID 2>/dev/null`
- Check nice value: `ps -o ni= -p $PID`
- Check if a file exists with correct PID: `cat answer.txt` matches expected
- For htop/btop levels: check process state changed after player exits

---

### 3.9 systemd-game (Phase 3)

**Dependency:** systemd (Linux only)
**Levels:** 25 (20 regular + 2 boss fights + 3 checkpoints)

#### Architecture Decision

systemd operations require root and affect the real system. We run inside a container (or systemd-nspawn) with its own systemd init. This gives a real systemd environment that's fully isolated.

```bash
# We use systemd-nspawn or a Docker container with systemd as PID 1
# Player connects via machinectl shell or docker exec
```

**Alternative for simpler levels:** Many levels just need to read/understand systemd, not modify it. For those, we can use `systemctl --user` which doesn't require root and runs in user-space.

#### Level Map

```
BEGINNER (0-9): Service Management
  0  — systemctl status (read the output for a running service)
  1  — systemctl start / stop (start and stop a service)
  2  — systemctl restart / reload (difference between them)
  3  — systemctl enable / disable (auto-start on boot)
  4  — systemctl is-active / is-enabled (check service state)
  5  — systemctl list-units --type=service (list all services)
  6  — systemctl list-unit-files (list all available unit files)
  7  — systemctl mask / unmask (prevent a service from starting at all)
  8  — systemctl daemon-reload (when to use it and why)
  9  — Unit file anatomy (read a .service file, identify key directives)
  BOSS 01 — A service is failing. Read its status, check logs, identify the
            problem, fix the unit file, reload, start, enable it.

INTERMEDIATE (10-17): journalctl and Unit Files
  10 — journalctl -u service (read logs for one service)
  11 — journalctl -f (follow logs in real time)
  12 — journalctl --since/--until (time-based log filtering)
  13 — journalctl -p err (filter by priority/severity)
  14 — Write a basic .service unit file ([Unit], [Service], [Install])
  15 — ExecStart, ExecStop, ExecReload directives
  16 — Restart policies (Restart=on-failure, RestartSec)
  17 — Environment and EnvironmentFile directives
  BOSS 02 — Write a complete .service file for a custom app: correct
            dependencies, environment from file, restart on failure,
            proper logging, install target

ADVANCED (18-22): Timers and Targets
  18 — systemctl list-timers (understand timer units)
  19 — Write a .timer unit (replace a cron job with systemd timer)
  20 — Targets (multi-user.target, graphical.target, rescue.target)
  21 — systemctl get-default / set-default (change default target)
  22 — Dependencies (After, Requires, Wants, Conflicts)

MASTER (23-24)
  23 — systemd-analyze (boot time, critical-chain, blame)
  24 — FINAL BOSS — System won't boot properly: a service has a circular
       dependency, a timer is misconfigured, a masked service is needed.
       Analyze with systemd-analyze, fix all issues, verify boot succeeds.
```

#### Sandbox Strategy

```bash
# For user-level commands (most beginner/intermediate levels):
# Use systemctl --user with custom unit files in ~/.config/systemd/user/

# For root-level commands (advanced/master levels):
# Use a Docker container with systemd as init:
# docker run -d --privileged --name systemd_game \
#   --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
#   systemd-game-image
```

#### Important Note for Agents
Linux-only game. Must detect at startup if systemd is available (`systemctl --version`). For beginner levels, prefer `systemctl --user` to avoid root requirement. For advanced levels that need root, use a container with systemd as PID 1.

---

### 3.10 ssh-game (Phase 4)

**Dependency:** openssh-client, openssh-server (in container)
**Levels:** 25 (20 regular + 2 boss fights + 3 checkpoints)

#### Level Map

```
BEGINNER (0-9): Connection Basics
  0  — ssh user@host (connect to a container running sshd)
  1  — ssh -p PORT (connect on non-standard port)
  2  — ssh-keygen (generate a key pair)
  3  — ssh-copy-id (set up passwordless auth)
  4  — ~/.ssh/config (create host aliases with Host/HostName/User/Port)
  5  — SSH key types (ed25519 vs rsa — generate the right one)
  6  — Known hosts (understand and manage ~/.ssh/known_hosts)
  7  — ssh-agent (add key, forward agent)
  8  — scp basics (copy file to/from remote)
  9  — sftp basics (interactive file transfer)
  BOSS 01 — Generate ed25519 key, deploy to 2 servers, set up config aliases,
            copy a file to one server and move it to the other via the first

INTERMEDIATE (10-17): Tunnels and Forwarding
  10 — Local port forwarding (ssh -L localPort:remoteHost:remotePort)
  11 — Remote port forwarding (ssh -R)
  12 — Dynamic forwarding / SOCKS proxy (ssh -D)
  13 — Jump hosts / ProxyJump (ssh -J jumphost target)
  14 — SSH multiplexing (ControlMaster, ControlPath, ControlPersist)
  15 — sshd_config basics (PermitRootLogin, PasswordAuthentication)
  16 — Restrict SSH access (AllowUsers, AllowGroups)
  17 — SSH banners and MOTD

ADVANCED (18-22): Security and Automation
  18 — SSH hardening (disable password auth, change port, limit retries)
  19 — SSH certificates (sign keys with a CA)
  20 — Forced commands (command= in authorized_keys)
  21 — SSH escape sequences (~. to disconnect, ~C for command line)
  22 — Port knocking concept (detect and respond to a knock sequence)

MASTER (23-24)
  23 — SSH bastion architecture (diagram + implement with 3 containers)
  24 — FINAL BOSS — Set up a secure SSH infrastructure: bastion host,
       2 backend servers, certificate-based auth, proper hardening,
       port forwarding for a web service, restrictive sshd_config.
```

#### Sandbox Strategy
Uses Docker containers running sshd as SSH targets. The player SSHes from their machine (or from a "jump" container) into game containers. All containers are on an isolated Docker network with the `cliacademy_` prefix.

---

## 4. Architecture: The Game Engine

### Target Repository Structure

```
cli-academy/
├── engine/
│   ├── engine.sh          # Core: progress, level ordering, main loop, CLI args
│   ├── validator.sh        # Validation framework (5 validator types)
│   └── ui.sh              # Colors, banners, prompts, emoji output
├── games/
│   ├── vim-game/
│   │   ├── play.sh        # Sources engine.sh, defines GAME_CMD="vim"
│   │   ├── game.conf      # Game metadata (name, description, tool dependency)
│   │   └── levels/
│   │       ├── level0/
│   │       │   ├── template.txt
│   │       │   ├── hint.txt
│   │       │   └── level.conf   # Declarative validation rules
│   │       └── ...
│   ├── git-game/
│   │   ├── play.sh
│   │   ├── game.conf
│   │   ├── sandbox.sh     # Git-specific: creates temp repos with history
│   │   └── levels/
│   ├── bash-game/
│   ├── tmux-game/
│   ├── docker-game/
│   ├── virsh-game/
│   ├── iptables-game/
│   ├── htop-game/
│   ├── systemd-game/
│   └── ssh-game/
├── web/                    # Future — web frontend
├── certs/                  # Future — certification definitions
├── docs/
│   └── plan.md            # This file
└── README.md
```

### Level Configuration Format (level.conf)

Each level is fully declarative. No bash code in the config.

```bash
# level.conf — parsed by engine's validator.sh
LEVEL_NAME="Delete the Noisy Line"
LEVEL_TIER="beginner"                        # beginner|intermediate|advanced|master|boss
TOOL_CMD='vim "$TMPFILE"'                    # what command opens for the user
TOOL_ARGS=""                                 # extra flags

# Validation
VALIDATE_TYPE="content_check"                # content_check|file_exists|diff_check|command_check|script
MUST_NOT_CONTAIN="NOISE_NOISE_NOISE"         # pipe-separated: "foo|bar|baz"
MUST_CONTAIN=""                              # pipe-separated
EXPECTED_FILE=""                             # for file_exists type
EXPECTED_CONTENT=""                          # for file_exists type
DIFF_EXPECTED=""                             # for diff_check type
CHECK_COMMAND=""                             # for command_check type
VALIDATE_SCRIPT=""                           # for script type: path to custom .sh

FAIL_MSG="The noisy line is still there."
PASS_MSG="Mission accomplished!"
```

### Validation Types

| Type | What It Does | Use Case |
|------|-------------|----------|
| `content_check` | Extracts `<<TASK>>..<<END>>` block, greps for must_contain / must_not_contain | Most text-editing levels |
| `file_exists` | Checks if file(s) exist with expected content | Multi-file, split, buffer levels |
| `diff_check` | Compares output against an expected file | Exact-output levels |
| `command_check` | Runs a shell command and checks exit code | git status, docker ps, etc. |
| `script` | Runs a custom validation bash script | Complex multi-step validations |

### Engine API (what engine.sh provides)

```bash
engine_init "$GAME_DIR"          # Initialize engine with game's root directory
engine_parse_args "$@"           # Handle reset/replay/hint/help
engine_run                       # Main loop: find next level, run it, check, continue

engine_get_tmpfile "$LEVEL"      # Get a clean temp file for the level
engine_get_workspace             # Get a workspace directory for multi-file levels
engine_cleanup                   # Clean up after level (called via trap EXIT)

engine_extract_task "$FILE"      # Extract <<TASK>>..<<END>> content
engine_log_pass "$LEVEL"         # Record level as completed
engine_log_fail "$LEVEL" "$MSG"  # Display failure with hint suggestion
```

### Platform Compatibility Matrix

| Game | Linux | macOS | WSL | Notes |
|------|-------|-------|-----|-------|
| vim-game | Yes | Yes | Yes | No special requirements |
| git-game | Yes | Yes | Yes | |
| bash-game | Yes | Yes | Yes | Needs bash >= 4.0 (macOS ships 3.2, need brew bash) |
| tmux-game | Yes | Yes | Yes | |
| docker-game | Yes | Yes | Yes | Docker Desktop on macOS/WSL |
| virsh-game | Yes | No | Partial | Requires libvirt + KVM |
| iptables-game | Yes | No | No | Requires net namespaces |
| htop-game | Yes | Partial | Yes | /proc not available on macOS; strace = dtrace |
| systemd-game | Yes | No | Partial | Requires systemd |
| ssh-game | Yes | Yes | Yes | Uses Docker for sshd targets |

---

## 5. Phased Roadmap with Agent Tasks

### Phase 0: Stabilize vim-game (Week 1)
> **Status: NOT STARTED**
> **Goal:** Fix all critical bugs, improve .gitignore, add missing hints.

#### Tasks for Agent

```
TASK 0.1: Fix critical bugs
─────────────────────────
Repository: https://github.com/Stormbringer-v1/vim-game
Branch: fix/critical-bugs

Fix the following bugs in play.sh. Make each fix a separate, well-named commit.

BUG-01 (Level 25, line 362):
  The level always passes. The if/grep is a no-op followed by unconditional echo.
  FIX: Add real validation. Level 25 is about window splits (:vsplit).
  Check that win.txt or a split-related file was created, or check the template
  for evidence the user performed the split operation.
  Note: Review the template at levels/level25/template.txt to understand what
  the level is supposed to teach, then write appropriate validation.

BUG-02 (Level 28, lines 385-390):
  Level checks and modifies user's real ~/.vimrc. This is dangerous.
  FIX: Use an isolated vimrc. The level should:
  1. Create a .vimrc_level28 file (like levels 34-35 already do)
  2. Launch vim with: vim -u .vimrc_level28 "$TMP_FILE"
  3. Validate against .vimrc_level28 instead of ~/.vimrc
  4. Clean up .vimrc_level28 after pass
  Update the template instructions to tell the user to edit .vimrc_level28.

BUG-03 (Level 45, line 638):
  Uses `break` inside run_level() which is a function, not a loop.
  The `clean()` helper uses `return 1` but the calling code uses `|| break`.
  FIX: Replace `|| break` with `|| return` throughout Level 45's validation.
  Test that failure messages display correctly and the level can be retried.

BUG-04 (Lines 19, 33):
  No validation on user-supplied level numbers for replay and hint commands.
  FIX: Add validation after lines 14 and 28:
    if [[ ! "$2" =~ ^[a-z0-9]+$ ]]; then
      echo "Invalid level: $2"
      exit 1
    fi

BUG-05 (Line 58):
  mktemp call is unquoted and behavior differs between Linux/macOS.
  FIX: Change to:
    TMP_FILE="$(mktemp "/tmp/vimlevel${LEVEL}.XXXXXX")"

BUG-06 (Lines 308, 418):
  Uses \b word boundary which is not POSIX grep.
  FIX: Replace \b with \< and \> for word boundaries:
    Line 308: change \bteh\b to \<teh\>
    Line 418: change \bteh\b to \<teh\>
    Line 563: change \bTODO\b to \<TODO\>

After all fixes, run through levels 25, 28, 45 manually to verify.
```

```
TASK 0.2: Fix .gitignore
─────────────────────────
Replace .gitignore contents with:

progress.log
.DS_Store
*.swp
*.swo
*~

# Files created during gameplay
.vimrc_level*
mysecondfile.txt
otherside.txt
secondfile.txt
tabfile.txt
win.txt
source.txt
dest.txt
fileA.txt
fileB.txt
fileC.txt
alpha.txt
beta.txt
gamma.txt
main.py
utils.py
readme.txt
header.txt
log.txt
mysession.vim
workfile.txt
file1.txt
file2.txt

Also: remove .DS_Store from tracking:
  git rm --cached .DS_Store
```

```
TASK 0.3: Add missing hints
────────────────────────────
Write hint.txt files for ALL levels that currently lack them.
Levels missing hints: 11, 12, 14, 15, 16, 17, 18, 19, 20,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45

Guidelines:
- Each hint should be 2-5 lines max
- Give the KEY command or concept, not the full solution
- Match the tone of existing hints (see levels/level0/hint.txt through level10/hint.txt)
- Format: plain text, no markdown, no emoji

Read each level's template.txt to understand what the level teaches before writing the hint.
```

---

### Phase 1: Engine Extraction + git-game (Weeks 2–7)
> **Status: NOT STARTED**
> **Depends on:** Phase 0 complete
> **Goal:** Extract reusable engine, refactor vim-game to use it, build git-game.

#### Tasks for Agent

```
TASK 1.1: Create cli-academy monorepo
──────────────────────────────────────
Create a new repository: cli-academy

Directory structure:
  cli-academy/
  ├── engine/
  │   ├── engine.sh
  │   ├── validator.sh
  │   └── ui.sh
  ├── games/
  │   └── vim-game/        (migrated from standalone repo)
  ├── docs/
  │   └── plan.md
  ├── README.md
  ├── LICENSE (MIT)
  └── .gitignore

The standalone vim-game repo remains as-is (for people who just want vim).
The cli-academy repo will contain a copy that uses the shared engine.
```

```
TASK 1.2: Build engine.sh
─────────────────────────
Extract from vim-game's play.sh into a sourceable library.

engine.sh must provide:
  - engine_init "$GAME_DIR"
      Sets up GAME_DIR, PROGRESS_FILE, discovers levels
  - engine_parse_args "$@"
      Handles: reset, replay <N>, hint <N>, help, (no args = play)
      Input validation on all arguments
  - engine_run
      Main loop: find first incomplete level, call game's run_level, continue prompt
  - engine_get_tmpfile "$LEVEL"
      Creates safe temp file, registers for cleanup
  - engine_extract_task "$FILE"
      Extracts content between <<TASK>> and <<END>> markers
  - engine_log_pass "$LEVEL"
      Writes to progress file, shows success message
  - engine_log_fail "$LEVEL" "$MSG"
      Shows failure message + hint suggestion if available
  - engine_cleanup
      Removes temp files (called via trap on EXIT)

Requirements:
  - Must work on both Linux and macOS (test with both GNU and BSD tools)
  - Must use `set -euo pipefail`
  - Must trap EXIT for cleanup
  - Must validate all external input
  - Must use POSIX-compatible grep (no \b, use \<\> for word boundaries)
  - Progress file writes must be append-only, with file locking if possible
```

```
TASK 1.3: Build validator.sh
────────────────────────────
Create the validation framework. Must parse level.conf and execute the right validator.

Implement 5 validators:

1. content_check
   - Extracts <<TASK>>..<<END>> block from the temp file
   - Checks MUST_NOT_CONTAIN (pipe-separated patterns, all must be absent)
   - Checks MUST_CONTAIN (pipe-separated patterns, all must be present)
   - Returns 0 on pass, 1 on fail with descriptive message

2. file_exists
   - Checks EXPECTED_FILE exists
   - If EXPECTED_CONTENT set, greps for it in the file
   - Cleans up created files after validation
   - Returns 0/1

3. diff_check
   - Compares temp file (or extracted task content) against DIFF_EXPECTED file
   - Returns 0/1

4. command_check
   - Runs CHECK_COMMAND in a subshell
   - Returns the command's exit code
   - Captures stdout for detailed error messages

5. script
   - Sources and runs VALIDATE_SCRIPT
   - Script receives $TMPFILE, $LEVEL, $GAME_DIR as arguments
   - Returns script's exit code

The validate() function:
  - Reads level.conf from levels/level$N/level.conf
  - Calls the appropriate validator
  - Returns pass/fail
```

```
TASK 1.4: Build ui.sh
─────────────────────
UI helper library. All user-facing output goes through these functions.

Provide:
  - ui_banner "$TEXT"         # Big decorative banner for game start
  - ui_success "$TEXT"        # Green success message with 🎉
  - ui_fail "$TEXT"           # Red failure message with ❌
  - ui_warn "$TEXT"           # Yellow warning
  - ui_info "$TEXT"           # Blue info
  - ui_hint_tip "$LEVEL"     # "Need help? Run: ./play.sh hint N"
  - ui_continue_prompt       # "Continue to next level? (y/N)"
  - ui_progress "$DONE" "$TOTAL"  # Progress bar or fraction

Requirements:
  - Detect if terminal supports color (check $TERM and tput)
  - Gracefully degrade to plain text if no color support
  - Consistent emoji usage across all games
  - No hardcoded escape codes — use tput
```

```
TASK 1.5: Refactor vim-game to use engine
──────────────────────────────────────────
Convert games/vim-game/play.sh to a thin wrapper:

  #!/usr/bin/env bash
  GAME_DIR="$(cd "$(dirname "$0")" && pwd)"
  source "${GAME_DIR}/../../engine/engine.sh"
  source "${GAME_DIR}/../../engine/validator.sh"
  source "${GAME_DIR}/../../engine/ui.sh"

  engine_init "$GAME_DIR"
  engine_parse_args "$@"
  engine_run

Convert ALL 46 levels to use level.conf files.
The case statement should be COMPLETELY ELIMINATED.

For levels that need custom validation scripts (levels 21, 25, 28, 40, 45):
  - Create levels/levelN/validate.sh
  - Set VALIDATE_TYPE="script" and VALIDATE_SCRIPT="validate.sh" in level.conf

VERIFICATION: All 46 levels must still pass/fail correctly after refactor.
Test every single level. Document any behavior changes.
```

```
TASK 1.6: Design and build git-game
────────────────────────────────────
Build the git-game using the level map from Section 3.2 of this plan.

Create:
  games/git-game/
  ├── play.sh              # Thin wrapper sourcing engine
  ├── game.conf            # name="git-game", tool_dependency="git"
  ├── sandbox.sh           # Creates/destroys temp git repos (see Section 3.2)
  └── levels/
      ├── level0/
      │   ├── template.txt
      │   ├── hint.txt
      │   ├── level.conf
      │   └── setup.sh     # Creates initial repo state for this level
      └── ...

Follow the sandbox strategy and validation approach from Section 3.2.
Every level must have: template.txt, hint.txt, level.conf, setup.sh.
Test every level on both Linux and macOS.
```

---

### Phase 2: bash-game + tmux-game + docker-game (Weeks 8–15)
> **Status: NOT STARTED**
> **Depends on:** Phase 1 complete, engine proven with 2 games
> **Goal:** 3 more games. One every ~2.5 weeks.

#### Tasks for Agent

```
TASK 2.1: Build bash-game
─────────────────────────
Build using the level map from Section 3.3.
Follow the sandbox strategy from Section 3.3.
40 levels across 4 tiers + boss fights.

NOTE: bash-game has unique validation — player writes solution.sh scripts
that get run with test inputs. The validator must:
  1. Run solution.sh with test inputs
  2. Capture stdout, stderr, exit code
  3. Compare against expected output
  4. Check for required patterns (e.g., must use 'trap' for trap levels)
```

```
TASK 2.2: Build tmux-game
─────────────────────────
Build using the level map from Section 3.4.
Follow the sandbox strategy from Section 3.4.
30 levels. CRITICAL: use isolated tmux socket (tmux -L).

NOTE: tmux validation happens AFTER the player exits tmux.
Use tmux -L $SOCKET commands to query the state.
```

```
TASK 2.3: Build docker-game
───────────────────────────
Build using the level map from Section 3.5.
Follow the sandbox strategy from Section 3.5.
35 levels. CRITICAL: all resources use "cliacademy_" prefix.

NOTE: Must check Docker is installed and running at game startup.
cleanup_sandbox MUST be bulletproof — never leave orphaned containers.
```

---

### Phase 3: virsh-game + iptables-game + htop-game + systemd-game (Weeks 16–26)
> **Status: NOT STARTED**
> **Depends on:** Phase 2 complete, 5 games stable
> **Goal:** 4 more games covering infrastructure and system administration.

#### Tasks for Agent

```
TASK 3.1: Build virsh-game
──────────────────────────
Build using the level map from Section 3.6.
Follow the sandbox strategy from Section 3.6.
25 levels. Ship pre-built XML definitions for domain/network/pool.

PREREQUISITE CHECK at startup:
  - libvirtd running
  - user in libvirt group
  - /dev/kvm exists (for full functionality)
  - virsh command available
```

```
TASK 3.2: Build iptables-game
─────────────────────────────
Build using the level map from Section 3.7.
Follow the sandbox strategy from Section 3.7.
30 levels. LINUX ONLY — requires network namespaces.

CRITICAL SAFETY:
  - NEVER run iptables commands on the host
  - ALL firewall operations inside network namespaces
  - cleanup_sandbox must delete all namespaces and veth pairs
  - Requires sudo — check at startup
```

```
TASK 3.3: Build htop-game
─────────────────────────
Build using the level map from Section 3.8.
Follow the sandbox strategy from Section 3.8.
20 levels. Spawn background processes for player to manage.

NOTE: cleanup MUST kill all spawned processes. Track PIDs carefully.
Some levels are "read and answer" (write PID or info to a file).
Some levels are "do something" (kill, renice a process).
```

```
TASK 3.4: Build systemd-game
─────────────────────────────
Build using the level map from Section 3.9.
Follow the sandbox strategy from Section 3.9.
25 levels. Use systemctl --user for beginner levels,
container with systemd for advanced levels.
```

---

### Phase 4: ssh-game + Web Platform + Certifications (Weeks 27–40)
> **Status: NOT STARTED**
> **Depends on:** Phase 3 complete
> **Goal:** Final game, web platform, certification system

*Detailed agent tasks will be written when we reach this phase.*

Key deliverables:
- ssh-game (25 levels, see Section 3.10)
- academy.snapsecurity.org web frontend
- Sandboxed container backend (xterm.js + ephemeral containers)
- User accounts and progress tracking
- Certification engine and payment processing

---

## 6. Agent Operating Instructions

### For Any Agent Working on This Project

**Before starting work:**
1. Read THIS FILE (plan.md) completely
2. Check the "Phase Status" at the top of each phase section
3. Read the specific TASK assigned to you
4. Read the relevant GAME SECTION (3.1–3.10) for sandbox strategy and validation approach
5. Clone the relevant repo(s)
6. Check existing code patterns before writing new code

**Code standards:**
- All game code is bash. No Python, no Node, no external dependencies beyond the tool being taught.
- `set -euo pipefail` in every script
- POSIX-compatible where possible (grep, sed, awk — no GNU-only flags)
- Test on Linux AND macOS (unless the game is marked Linux-only)
- Meaningful commit messages: `fix(level25): add real validation for window splits`
- One logical change per commit

**Validation rules:**
- Every level MUST have: template.txt, level.conf, hint.txt
- Never modify user's home directory files (no ~/.vimrc, ~/.bashrc, ~/.gitconfig)
- All temp files in /tmp, cleaned up via trap
- All gameplay-created files cleaned up after validation
- Games that require elevated privileges (iptables, systemd) must check at startup and fail gracefully

**Level design rules:**
- One new concept per level (never two)
- Smooth difficulty curve within each tier
- Boss fights combine 3-5 skills from prior levels
- Hints give the KEY command, not the solution
- Templates are self-contained instructions — user should never need external docs

**Testing:**
- After any change to engine code, run ALL levels of ALL games
- After adding a new level, test it 3 times: once correct, once wrong, once edge case
- After any refactor, do a full regression test

### For the Lead Architect (Claude Opus in Cowork)

My responsibilities:
- Review all agent output before it's merged
- Update this plan.md after each phase completion
- Make architecture decisions when agents encounter ambiguity
- Design level content and validation strategies
- Quality control: reject work that doesn't meet standards
- Adjust timelines based on actual progress

---

## 7. Resources & Cost Estimates

| Phase | Monthly Cost | What |
|-------|-------------|------|
| 0–2 (Terminal only) | ~$20 | AI subscription only |
| 3 (Infra games) | ~$20 | AI subscription + maybe a test VPS ($5/mo) |
| 4 (Web platform) | $50–150 | VPS + domain + monitoring |
| 4 (Certifications) | $100–300 | Compute + Stripe + email |

---

## 8. Changelog

| Date | Change |
|------|--------|
| 2026-04-04 | Initial plan created. Audit of vim-game completed. Critical bugs identified. |
| 2026-04-04 | Expanded game catalog to 10 games with full level maps, sandbox strategies, and validation approaches. Added: vim, git, bash, tmux, docker, virsh, iptables/nftables, htop/btop, systemd, ssh. |
