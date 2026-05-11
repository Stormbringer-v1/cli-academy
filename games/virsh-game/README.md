# virsh Game

**Learn KVM/libvirt virtual machine management by playing a game in your terminal.**

virsh Game teaches you virsh through 27 progressive levels. You learn by doing — managing real virtual machines, networks, and storage pools. Each level teaches one virsh concept, and you progress by mastering each skill.

---

## Quick Start

```bash
cd cli-academy/games/virsh-game
./play.sh
```

**Requirements:**
- Linux with libvirtd running
- virsh command-line tool
- User must be in the libvirt group or have root access

---

## Setup

1. Install libvirt:
   ```bash
   # Ubuntu/Debian
   sudo apt install libvirt-daemon-system

   # Fedora
   sudo dnf install libvirt-daemon-system

   # Arch
   sudo pacman -S libvirt
   ```

2. Start and enable libvirtd:
   ```bash
   sudo systemctl start libvirtd
   sudo systemctl enable libvirtd
   ```

3. Add your user to the libvirt group:
   ```bash
   sudo usermod -aG libvirt $USER
   # Log out and back in for group changes to take effect
   ```

---

## Commands

```bash
./play.sh              # Start or resume from where you left off
./play.sh hint 5      # Get a hint for level 5
./play.sh replay 5     # Replay a completed level
./play.sh reset        # Reset all progress
```

---

## What You'll Learn

The game is divided into four tiers:

**Beginner (Levels 0-9)** — Domain basics. `virsh list`, `virsh define`, `virsh start`, `virsh shutdown`, `virsh destroy`, `virsh undefine`, `virsh dominfo`, `virsh console`, `virsh dumpxml`, `virsh edit`, `virsh autostart`.

**Intermediate (Levels 10-17)** — Storage and networking. Storage pools, volumes, virtual networks, NAT configuration, interface attachment.

**Advanced (Levels 18-22)** — Snapshots and monitoring. Create, list, revert, and delete snapshots. Monitor domain statistics with `virsh domstats`.

**Master (Levels 23-24)** — Expert operations. Block migration, diagnosing and fixing misconfigured domains.

---

## How It Works

Each level provides XML definitions for domains, networks, or storage. You run virsh commands to create and configure these resources. The game validates that you've completed the task correctly.

Your progress is saved automatically.

---

## Level Structure

Each level directory contains:
- `level.conf` — Level metadata and validation type
- `template.txt` — Instructions for the player
- `hint.txt` — Hint if stuck
- `sandbox.sh` — Sets up isolated game resources
- `validate.sh` — Validates the player's solution
- `*.xml` — Resource definitions (domains, networks, pools)

---

## Requirements

- Linux (virsh-game does NOT work on macOS or WSL without a Linux VM)
- libvirt daemon running
- KVM or QEMU virtualization support
- virsh >= 6.0

---

## License

MIT License. See [LICENSE](../../LICENSE) for details.