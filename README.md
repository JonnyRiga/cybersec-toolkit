# cybersec-toolkit

Offensive-security tooling maintained by [@JonnyRiga](https://github.com/JonnyRiga). Consolidates previously-separate repos into one home.

## Contents

| Directory | What it is |
|-----------|-----------|
| [`privy/`](./privy)           | Privilege-escalation enumeration — `privy.sh` (Linux) & `privy.ps1` (Windows). Runs structured phases, flags findings, and produces prioritised P1/P2/P3 exploit recipes. |
| [`credsniff/`](./credsniff)   | Targeted credential extraction and analysis for Linux post-exploitation. |
| [`nmap-auto/`](./nmap-auto)   | Lightweight network-recon wrappers — `nmapz` (two-phase nmap auto-chain), `psw` (ping sweep), `ips` (interface viewer). |
| [`webshell/`](./webshell)     | Retro-styled PHP webshell — password auth, command history, reverse shell launchers, file upload/download, sysinfo panel. |

Each subdirectory has its own README with usage, features, and detection coverage.

## Migrated from

- `JonnyRiga/privy-tool` → `privy/`
- `JonnyRiga/credsniff-tool` → `credsniff/`
- `JonnyRiga/nmap-auto-tool` → `nmap-auto/`

The old repos are archived and point here.

## Disclaimer

For authorised penetration testing, CTF competitions, and security research only. Do not use against systems you do not have explicit permission to test.
