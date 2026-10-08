# Known issues: tmux-game

Found by the solution scripts in tests/solutions/tmux-game/ (ticket T-SOL-tmux), run in the
harness environment described in tests/README.md. Levels are listed in LEVEL_ORDER order.

## level0: Validators prefix-match session names, so a differently named session passes
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
tmux -L kiprobe0 new-session -d -s intro2; tmux -L kiprobe0 has-session -t intro; echo "has-session -t intro rc=$?"; tmux -L kiprobe0 kill-server
has-session -t intro rc=0
tail -n 1 /tmp/t-sol-tmux/exp/l0-prefix.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 0 /tmp/t-sol-tmux/exp/l0-prefix.sh | tail -n 3
tmuxa new-session -d -s intro2
[PASS] You started tmux on an isolated socket.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): tmux_session_exists in validate_tmux_state.sh should use an exact-match target: tmuxa has-session -t "=$1". Same helper is used by levels 1, 9, boss01, 25 and 27 (and by the negative checks such as "! tmux_session_exists prod").
- Status: fixed by D-FIX-tmux (fix(tmux): match session names exactly and read window options with show-options)

## level3: Attach and detach: a no-op passes
- Kind: validator-weak
- Effect: no .wrong.sh possible
- Evidence:
```text
tail -n 1 /tmp/t-sol-tmux/exp/noop.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 3 /tmp/t-sol-tmux/exp/noop.sh | tail -n 3
true
[PASS] You attached and detached successfully.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
sed -n 5p /tmp/t-sol-tmux/exp/l3-wrong-try.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 3 /tmp/t-sol-tmux/exp/l3-wrong-try.sh | grep -v '^$' | tail -n 2
script -qec "tmux -L $TMUX_SOCKET attach -t attachme" /dev/null </dev/null >/dev/null 2>&1 &
no server running on /tmp/cla-verify.b6YXb6/tmux/tmux-0/tmuxgame_31769_19809
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): Record the attach in setup_sandbox (a client-attached hook that touches a marker file in the sandbox) and have validate.sh require the marker as well as zero clients. No .wrong.sh: the one realistic mistake (attach and never detach) could not be made to fail for that reason without a real terminal. The second evidence run attaches through script(1) in the background and ends with "no server running" (the session is gone) instead of a lingering client.

## level8: Kill a session: kill-server and kill-window also pass
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
tail -n 1 /tmp/t-sol-tmux/exp/l8-killserver.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 8 /tmp/t-sol-tmux/exp/l8-killserver.sh | tail -n 3
tmuxa kill-server
[PASS] Session removed successfully.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
tail -n 1 /tmp/t-sol-tmux/exp/l8-killwindow.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 8 /tmp/t-sol-tmux/exp/l8-killwindow.sh | tail -n 3
tmuxa kill-window -t deleteme:shell
[PASS] Session removed successfully.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): Create a second session (for example keepme) in setup_sandbox and require it to survive; today the check only asks that deleteme is gone, which is also true after kill-server or after closing the only window.

## level15: Preset layouts: any layout with equal pane heights passes, not only even-horizontal
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
tail -n 1 /tmp/t-sol-tmux/exp/l15-even-vertical.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 15 /tmp/t-sol-tmux/exp/l15-even-vertical.sh | tail -n 3
tmuxa select-layout -t layout:main even-vertical
[PASS] Layout preset applied.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
tail -n 1 /tmp/t-sol-tmux/exp/l15-tiled.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 15 /tmp/t-sol-tmux/exp/l15-tiled.sh | tail -n 3
tmuxa select-layout -t layout:main tiled
[PASS] Layout preset applied.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): Also require that all panes share the same pane_top (side by side, which is what even-horizontal produces), or compare #{window_layout} with the layout string of a reference window.

## level17: Synchronize panes: the validator can never pass on tmux 3.4
- Kind: validator-impossible
- Effect: xfail
- Evidence:
```text
tmux list-commands | grep '^show-window-options'
show-window-options (showw) [-gv] [-t target-window] [option]
tmux -L kiprobe17 new-session -d -s sync -n main; tmux -L kiprobe17 set-window-option -t sync:main synchronize-panes on; tmux -L kiprobe17 show-window-options -t sync:main -qv synchronize-panes; tmux -L kiprobe17 show-options -wqv -t sync:main synchronize-panes; tmux -L kiprobe17 kill-server
command show-window-options: unknown flag -q
on
/tmp/t-sol-tmux/verify-legacy.sh tmux-game 17 tests/solutions/tmux-game/17.sh | grep -v '^$' | tail -n 2
Expected synchronize-panes to be on.
VERDICT: FAIL (engine rc=1, timeout=30s)
```
- Suggested fix (dev team, not applied): In validate_tmux_state.sh, tmux_window_option_equals should call show-options (which does accept -q), for example: tmuxa show-options -wqv -t "$1" "$2". The last command in the evidence shows it prints on.
- Status: fixed by D-FIX-tmux (fix(tmux): match session names exactly and read window options with show-options)

## level19: Send keys: typing the word without running the command passes
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
tail -n 1 /tmp/t-sol-tmux/exp/l19-typed-only.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 19 /tmp/t-sol-tmux/exp/l19-typed-only.sh | tail -n 3
tmuxa send-keys -t send:main.1 synced
[PASS] Keys sent to target pane successfully.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): Require the command to have run: look for a line that is exactly synced (grep -qx) instead of the substring anywhere in the pane, since the typed command line already contains the word.

## level20: Copy mode: tmux set-buffer passes without using copy mode
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
tail -n 1 /tmp/t-sol-tmux/exp/l20-setbuffer.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 20 /tmp/t-sol-tmux/exp/l20-setbuffer.sh | tail -n 3
tmuxa set-buffer COPYME
[PASS] Copy mode succeeded.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): Have setup_sandbox install a pane-mode-changed hook that touches a marker file when copy mode is entered, and require the marker in validate.sh in addition to the buffer contents.

## level23: tmux.conf basics: the prefix line is never checked against the live server
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
tail -n 2 /tmp/t-sol-tmux/exp/l23-nosource.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 23 /tmp/t-sol-tmux/exp/l23-nosource.sh | tail -n 3
tmuxa set -g mouse on
printf "set -g prefix C-a\n" > .tmux_level23.conf
[PASS] tmux config basics complete.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): Also check tmuxa show-options -gv prefix is C-a (proves the file was loaded) and that the file contains the mouse line.

## level25: tmux scripting: an empty executable layout.sh passes
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
tail -n +3 /tmp/t-sol-tmux/exp/l25-emptyscript.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 25 /tmp/t-sol-tmux/exp/l25-emptyscript.sh | tail -n 3
touch layout.sh
chmod +x layout.sh
tmuxa new-session -d -s dev -n editor
tmuxa new-window -t dev: -n server
tmuxa new-window -t dev: -n logs
[PASS] tmux automation script works.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): Add a cheap structural check on the script itself (it must mention new-session and new-window); validators must not run the script, per the contract.

## level26: Hooks: the hook command is never checked
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
tail -n 2 /tmp/t-sol-tmux/exp/l26-fakehook.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 26 /tmp/t-sol-tmux/exp/l26-fakehook.sh | tail -n 3
tmuxa set-hook -g after-new-window "display-message hi"
tmuxa new-window -t hooks: -n hooked
[PASS] tmux hooks configured successfully.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): Require the stored hook to do the rename: tmuxa show-hooks -g after-new-window must contain rename-window hooked.

## level27: FINAL BOSS: an empty executable bootstrap.sh passes
- Kind: validator-weak
- Effect: informational
- Evidence:
```text
tail -n +3 /tmp/t-sol-tmux/exp/l27-emptyscript.sh; /tmp/t-sol-tmux/verify-legacy.sh tmux-game 27 /tmp/t-sol-tmux/exp/l27-emptyscript.sh | tail -n 3
touch bootstrap.sh
chmod +x bootstrap.sh
tmuxa new-session -d -s academy -n editor
tmuxa split-window -h -t academy:editor
tmuxa new-window -t academy: -n server
tmuxa new-window -t academy: -n logs
tmuxa new-window -t academy: -n shell
tmuxa set-option -g status-right LIVE
tmuxa set-option -g mouse on
[PASS] Final boss defeated! tmux-game is complete.
[INFO] See you next time! Exiting...
VERDICT: PASS (engine rc=0, timeout=30s)
```
- Suggested fix (dev team, not applied): Same structural check as level 25: bootstrap.sh must mention new-session, new-window, status-right and mouse.
