```
 ██████╗ ██████╗ ██╗██╗   ██╗██╗   ██╗
 ██╔══██╗██╔══██╗██║██║   ██║╚██╗ ██╔╝
 ██████╔╝██████╔╝██║██║   ██║ ╚████╔╝
 ██╔═══╝ ██╔══██╗██║╚██╗ ██╔╝  ╚██╔╝
 ██║     ██║  ██║██║ ╚████╔╝    ██║
 ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝     ╚═╝
```

# Privy — Privilege Escalation Enumeration

**Author:** Pentest-Ready

Two-platform privesc enumeration: `privy.sh` (Linux) and `privy.ps1` (Windows). Both run structured phases, flag findings in real time, and generate prioritised exploit path suggestions with copy-paste commands.

| Script | Platform | Version |
|--------|----------|---------|
| `privy.sh`  | Linux    | 1.6 |
| `privy.ps1` | Windows  | 1.1 |

---

## Usage

### Linux
```bash
chmod +x privy.sh
./privy.sh
```
Output: `./Privy/` — back up automatically on re-run.

### Windows
```powershell
powershell -ep bypass -File privy.ps1
```
Output: `.\Privy\` — back up automatically on re-run.

Both always produce two must-read files:
- `00-FINDINGS.txt` — triage summary of everything flagged
- `01-ExploitPaths.txt` — prioritised P1/P2/P3 exploit recipes

---

## Exploit Path Priorities

| Priority | Meaning |
|----------|---------|
| **[P1]** | Immediate — run it now, likely instant root/SYSTEM |
| **[P2]** | Likely root/SYSTEM — requires a step or two |
| **[P3]** | Investigate — depends on context |

---

## `privy.sh` — Linux (16 phases)

| Phase | Area | Output File |
|-------|------|-------------|
| 1  | System Information (kernel, OS, env, mounts) | `SysInfo.txt` |
| 2  | User & Group Information (sudo, sudoers, UID 0) | `UserGroupInfo.txt` |
| 3  | Passwd & Shadow Files | `Passwd.txt` / `Shadow.txt` |
| 4  | Services & Running Processes | `RootServices.txt` |
| 5  | Cron Jobs & Scheduled Tasks | `CronJobs.txt` |
| 6  | PATH & Environment (LD_PRELOAD, shell profiles) | `PATH-Info.txt` |
| 7  | Network Information (interfaces, firewall, NFS) | `NetworkInfo.txt` |
| 8  | SUID / SGID Binaries & Capabilities | `SUID-GUID.txt` |
| 9  | SSH Keys & Cloud Credentials | `SSHKeys.txt` |
| 10 | MySQL / PostgreSQL Database Info | `MySQL.txt` |
| 11 | Interesting Files & Logs | `InterestingLogs.txt` |
| 12 | File System Enumeration (backups, recent changes) | `FileSystem.txt` |
| 13 | Shell Histories | `Histories.txt` |
| 14 | Dev Tools & File Transfer Binaries | `DevTools.txt` |
| 15 | Third-Party Application CVE Check | `ThirdPartyApps.txt` |
| 16 | Exploit Path Suggestions (auto-generated) | `01-ExploitPaths.txt` |

**Detection coverage:**
- **Dangerous groups:** `docker`, `lxd`/`lxc`, `disk`
- **Sudo abuse:** NOPASSWD entries for shells, interpreters, editors, pagers, and 20+ file tools
- **SUID GTFOBins:** `bash`, `find`, `python`, `perl`, `vim`, `awk`, `env`, `tar`, `nmap`, `pkexec` (PwnKit), `screen`, and 50+ more
- **Capabilities:** `cap_setuid`, `cap_setgid`, `cap_dac_override`, `cap_sys_admin`, `cap_sys_ptrace`, `cap_net_raw`, `cap_fowner`
- **Cron & service hijacks:** Writable cron scripts, writable systemd units, writable `/etc/crontab`, writable MOTD scripts
- **Credential exposure:** Readable `/etc/shadow`, SSH private keys, `.netrc`, AWS/GCloud/Azure creds, MySQL/PostgreSQL no-password root, `.htpasswd`, `/var/backups/`
- **Container escapes:** Docker socket, lxd/lxc group, `/.dockerenv`
- **Third-party app CVEs (Phase 15):** Version-aware detection for 8 common self-hosted services with known exploit paths auto-generated in `01-ExploitPaths.txt`

| App | Key CVEs |
|-----|----------|
| Gogs | CVE-2024-39930/31/32/33 (RCE < 0.13.0), CVE-2022-0415 |
| Gitea | Security fixes < 1.22.0, CVE-2022-1058 |
| Jenkins | CVE-2024-23897 (unauth file read < 2.442), CVE-2023-27898 |
| Grafana | CVE-2021-43798 (path traversal 8.0.0–8.3.0) |
| MinIO | CVE-2023-28432 (env var leak) |
| Flowise | CVE-2025-59528 (RCE), CVE-2025-58434 (reset token leak < 3.0.6) |
| Nextcloud | CVE-2023-48239 (auth bypass < 27.1.3), CVE-2024-37302 |
| Portainer | CVE-2022-26960 (path traversal < 2.11.1) |

- **Kernel CVEs:** DirtyCow (CVE-2016-5195), DirtyPipe (CVE-2022-0847), Baron Samedit (CVE-2021-3156), PwnKit (CVE-2021-4034)
- **Other:** NFS `no_root_squash`, multiple UID 0 accounts, writable `/etc/passwd`, writable PATH dirs, writable LD config, active tmux sessions

**Requirements:** Bash 4+, standard Linux utils (`jq` recommended for Flowise version detection). No root required.

---

## `privy.ps1` — Windows (12 phases)

| Phase | Area | Output File |
|-------|------|-------------|
| 1  | System Information (OS, hotfixes) | `SysInfo.txt` |
| 2  | User & Group Info (privs, cmdkey, policy) | `UserGroupInfo.txt` |
| 3  | Services (unquoted paths, writable bins) | `Services.txt` |
| 4  | Scheduled Tasks | `ScheduledTasks.txt` |
| 5  | Registry (AlwaysInstallElevated, AutoLogon, UAC) | `Registry.txt` |
| 6  | Network (firewall, WiFi keys, shares) | `NetworkInfo.txt` |
| 7  | Credential Hunting (unattend, web.config, SSH, browsers) | `Credentials.txt` |
| 8  | Installed Software | `Software.txt` |
| 9  | File System (writable system paths, flag search) | `FileSystem.txt` |
| 10 | Histories (PSReadLine all users, doskey) | `Histories.txt` |
| 11 | Dev Tools & Transfer Vectors | `DevTools.txt` |
| 12 | Exploit Path Suggestions (auto-generated) | `01-ExploitPaths.txt` |

**Detection coverage:**
- **Dangerous privileges:** `SeImpersonate`, `SeAssignPrimaryToken`, `SeBackup`, `SeRestore`, `SeTakeOwnership`, `SeDebug`, `SeLoadDriver`, `SeCreateToken`, `SeTcb`, `SeManageVolume` — each with matching exploit recipe
- **Service misconfigurations:** Unquoted paths, writable service binaries, writable scheduled task scripts
- **Registry privesc:** `AlwaysInstallElevated`, AutoLogon plaintext credentials, `LocalAccountTokenFilterPolicy` (PTH)
- **Credential hunting:** Unattend/Sysprep XML, PSReadLine history (all users), web.config, cmdkey, SSH keys under `C:\Users`, browser login data (Chrome/Edge/Brave/Firefox), DPAPI master keys
- **Network:** Saved WiFi profiles (key recovery), firewall inbound rules, SMB shares
- **Potato family:** PrintSpoofer, GodPotato, JuicyPotatoNG references with copy-paste commands
- **CVEs:** PrintNightmare (CVE-2021-1675 / CVE-2021-34527) with Spooler-service gating
- **Other:** Writable system paths, AV/EDR detection, interesting installed software

**Requirements:** PowerShell 5+, no admin needed (scans what current user can see).

---

## Disclaimer

For authorised penetration testing, CTF competitions, and security research only. Do not use against systems you do not have explicit permission to test.
