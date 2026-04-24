# nmap-auto-tool

A set of lightweight bash tools for network reconnaissance on Kali Linux.

## Tools

### `ips`
Displays all local network interfaces with their IP addresses, MAC, MTU, and state — color coded.

```bash
ips
```

### `psw` — Ping Sweep
Sweeps a /24 subnet for live hosts. Runs ICMP first via `fping`, falls back to `arp-scan` if no responses.

```bash
psw
# Enter a Subnet IP: 10.10.10
```

- Detects and labels your own machine as `[you]`
- Reverse DNS lookup on each host
- Labels which scan method found each host (`[ICMP]` or `[ARP]`)

### `nmapz` — Nmap Auto-Chain
Two-phase nmap wrapper. Runs a fast discovery sweep across all 65535 ports, parses open ports, then automatically fires a full scan on only what's listening.

```bash
# Auto-chain (discovery → full scan)
nmapz 10.10.10.1 initial

# Skip discovery, full scan on known ports
nmapz -p 22,80,443 10.10.10.1 targeted

# Xmas scan discovery → full scan (for filtered/firewalled hosts)
nmapz -x 10.10.10.1 xmas
```

**Phase 1 — Discovery:**
```
nmap -sS -T4 -p- --open -n -Pn
```

**Phase 2 — Full scan on found ports:**
```
nmap -sS -T4 -sC -sV -O -Pn -p <found ports>
```

Output is saved to `./nmap/` relative to your working directory:
```
nmap/initial_discovery.{nmap,xml,gnmap}
nmap/initial_full.{nmap,xml,gnmap}
```

## Installation

```bash
sudo cp ips psw nmapz /usr/local/bin/
sudo chmod +x /usr/local/bin/ips /usr/local/bin/psw /usr/local/bin/nmapz
```

## Dependencies

| Tool | Used by | Install |
|------|---------|---------|
| `fping` | psw | `apt install fping` |
| `arp-scan` | psw | `apt install arp-scan` |
| `nmap` | nmapz | `apt install nmap` |
| `iproute2` | ips, psw | pre-installed on Kali |

## Notes

- `nmapz` and `psw` (ARP mode) require root or sudo
- Xmas scans are unreliable against Windows hosts
- `psw` accepts subnet input as `10.10.10`, `10.10.10.`, or `10.10.10.0`
