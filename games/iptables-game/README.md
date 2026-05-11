# iptables Game

**Learn Linux firewall configuration with iptables and nftables through interactive network namespace exercises.**

iptables Game teaches you firewall rules using isolated network namespaces. Each level runs in a fully isolated Linux network — your real firewall rules are never touched. You learn by writing real iptables and nftables rules that control packet flow in a sandboxed environment.

---

## Quick Start

```bash
cd cli-academy/games/iptables-game
sudo ./play.sh
```

**Requirements:**
- Linux (native, not macOS or WSL)
- iptables
- iproute2
- sudo/root access (needed for network namespaces)

---

## Setup

1. Install dependencies:
   ```bash
   # Ubuntu/Debian
   sudo apt install iptables iproute2

   # Fedora
   sudo dnf install iptables iproute
   ```

2. Run with sudo (required for network namespace operations):
   ```bash
   sudo ./play.sh
   ```

---

## Commands

```bash
sudo ./play.sh              # Start or resume
sudo ./play.sh hint 5      # Get a hint for level 5
sudo ./play.sh replay 5    # Replay a completed level
sudo ./play.sh reset        # Reset all progress
```

---

## What You'll Learn

The game covers three major areas:

**iptables Fundamentals (Levels 0-9)** — Chains, targets, listing rules, basic ACCEPT/DROP/REJECT, default policies, connection tracking, saving rules.

**Advanced iptables (Levels 10-19)** — LOG targets, rate limiting, port ranges, NAT (SNAT/DNAT), custom chains, connection tracking, Docker interaction.

**nftables (Levels 20-27)** — nft command syntax, tables and chains, sets and maps, counters, scripting, translating iptables rules to nftables.

---

## How It Works

Each level runs inside an isolated Linux network namespace. You get a clean slate to write firewall rules. The game validates your rules by testing actual network connectivity. Your real system firewall is completely unaffected.

---

## Requirements

- **Linux only** — This game cannot run on macOS or WSL without a Linux VM
- Root/sudo access (required for network namespaces)
- iptables >= 1.8
- iproute2

---

## License

MIT License. See [LICENSE](../../LICENSE) for details.