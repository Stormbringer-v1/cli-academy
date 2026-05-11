# SysOps Game

**Learn Linux process management, system monitoring, and operational troubleshooting through interactive challenges.**

SysOps Game teaches you the core skills every sysadmin and DevOps engineer needs: diagnosing misbehaving systems. Players learn to manage processes with ps, kill, nice, and renice; monitor with top, htop, btop, vmstat, and iostat; debug with strace, lsof, ss, and /proc; and solve multi-layered incidents where everything breaks at once.

---

## Quick Start

```bash
cd cli-academy/games/sysops-game
./play.sh
```

**Requirements:**
- Linux (recommended; levels 0-9 work on macOS)
- Standard Linux process tools: ps, kill, pgrep, ss, lsof, nice, renice
- For advanced levels: htop, btop, strace, vmstat, iostat (all available in standard repos)

---

## Setup

```bash
# Ubuntu/Debian
sudo apt install procps iproute2 lsof htop btop sysstat strace

# Fedora
sudo dnf install procps-ng iproute lsof htop btop sysstat strace

# Arch
sudo pacman -S procps-ng iproute2 lsof htop btop sysstat strace
```

---

## Commands

```bash
./play.sh              # Start or resume
./play.sh hint 5      # Get a hint for level 5
./play.sh replay 5    # Replay a completed level
./play.sh reset        # Reset all progress
```

---

## What You'll Learn

**Beginner (Levels 0-9)** — Process discovery and signals. ps aux, pgrep, kill, signals (SIGTERM/SIGKILL/SIGHUP/SIGSTOP/SIGCONT), top basics, htop basics, htop tree view.

**Intermediate (Levels 10-19)** — Priority and resources. nice, renice, /proc/PID/{status,cmdline,environ,fd}, /proc/meminfo, /proc/cpuinfo, load average, nproc/ulimit.

**Advanced (Levels 20-29)** — Monitoring and debugging. lsof, lsof +D, lsof -i, ss, ss state filters, fuser, strace, vmstat/iostat/mpstat.

**Master (Levels 30-34)** — Complex diagnostics. btop deep dive, process forensics (/proc + lsof + strace), resource leak diagnosis, performance bottleneck analysis.

**Final Boss** — "Midnight Incident": 4 CPU hogs, 2 processes fighting over a file lock, 1 process with 500+ leaked FDs, 1 rogue listener, 1 zombie chain, load 15+ on 4-core machine. Fix everything in the right order.

---

## How It Works

The game spawns background processes, CPU hogs, zombies, file locks, port listeners, and FD leaks. Players investigate and fix them using Linux tools. Validation checks your answer file and process state. All rogue processes are cleaned up when you exit.

---

## Requirements

- Linux (recommended; core levels work on macOS)
- ps, kill, pgrep, ss, lsof, nice, renice
- Optional: htop, btop, strace, vmstat, iostat, mpstat

---

## License

MIT License. See [LICENSE](../../LICENSE) for details.